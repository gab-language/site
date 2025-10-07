+++
date = '2025-10-02T09:57:01-04:00'
draft = false
title = 'IO'
+++
## Why it matters
In a lot of programs that we write today, the bottleneck for performance of our applications isn't
actually the work we're doing on the CPU. Its more likely that the **IO Operations**, such as sending/receiving data over the
network or writing and reading files, will end up blocking the CPU from doing its work.

Programming languages solve this issue in different ways. At the lowest level, languages need a way of telling the OS
that some IO work needs to be done, without blocking the thread. NodeJS for example uses libuv, a c library which utilizes
an eventloop and threadpool to perform IO. The user in Javascript issues IO **requests** to the libuv loop, which process them
as it can with its workers. The Javascript runtime then yields that function until the IO request is complete - allowing other JS code to
run on the thread. Python's *asyncio* and Rust's *tokio* work similarly.

libuv works fantastically well, but there were some problems when it comes to integrating it into Gab's IO module.
- At the c-level, libuv's api uses callbacks. This is inconvenient.
- libuv spawns a thread pool, which will compete with Gab's.
- Gab native modules prefer single-header libraries (which libuv is not) to avoid linking and to ease cross-compilation.

For these reasons, I created my own eventloop library in c: [TeddyRandby/qio](https://github.com/TeddyRandby/qio)

### QIO - A simple event loop.
This library uses OS-specific apis to implement the event loop as efficiently as possible. It also allows for the
user to submit IO-requests from multiple threads (the library is thread-safe in this way). Here is a quick overview of the api:
```c
/*
 * Abstraction over os file/pipe/console/socket types.
 * (basically, a HANDLE on Windows and an int everywhere else)
 */
typedef /* os_fd_type */ qfd_t;

/*
 * A qd (pronounced 'kid') is a handle representing a single, 'queued' IO operation.
 *
 * It is used to:
 *  - Check on the status of its corresponding operation.
 *  - Get the result of its operation
 */
typedef int32_t qd_t;

/*
 * %----------------%
 * | QD Operations |
 * %----------------%
 */

/*
 * This function is *not* blocking. It will immediately return:
 *  - nonzero if the corresponding operation is complete.
 *  - zero if the operation is still in progress.
 */
int8_t  qd_status(qd_t qd);

/*
 * This operation is *blocking*. It blocks the caller until the qd's corresponding operation is complete,
 * and returns the return value of the queued operation.
 */
int64_t qd_result(qd_t qd);

/*
 * This operation is *blocking*. It blocks until the operation is complete - 
 * and then reclaims the memory of `qd` for future operations.
 * 
 *  NOTE:
 *      Currently, there is a 'free list' protected by a mutex.
 *      This allows multiple threads to queue and destroy
 *      operations in parallel.
 *
 *      This does mean there will probably be a lot of contention
 *      on this one lock. It may be possible to implement this more
 *      efficiently with a single atomic qd_t as the head of the list.
 */
void qd_destroy(qd_t qd);

/*
 * %-----------%
 * | QIO Setup |
 * %-----------%
 */

/*
 * Initialize QIO. This should only be called *once*.
 * This sets up platform-specific IO datastructures, as well as performing
 * any other initialization necessary.
 */
int32_t qio_init(uint64_t size);

/*
 * Run the event loop.
 */
int32_t qio_loop();

/*
 * De-initialize QIO. This should only be called *once*.
 *
 * In theory, this destroys the platform-specific IO datastructures setup by qio_init.
 * 
 * Currently this just leaks all memory. Who cares? This stuff lives the whole
 * lifetime of the thread its on anyway.
 */
void qio_destroy(uint64_t size);

/* 
 * %----------%
 * | QIO API |
 * %---------%
 * The following are the 'queued' versions of corresponding POSIX functions.
 * Hopefully the interfaces are self explanatory if you're familiar with POSIX.
 */
qd_t qopen(const char* path);
qd_t qopenat(qfd_t fd, const char* path);

qd_t qwrite(qfd_t fd, uint64_t n, const uint8_t buf[n]);
qd_t qread(qfd_t fd, uint64_t offset, uint64_t n, uint8_t buf[n]);

qd_t qclose(qfd_t fd);

/*
* QIO combines the socket type\domain\protocol arguments that
* are found in posix into configurations that are common and
* cross-platform. These are TCP and UDP.
*
* Note: These use IPv6 exclusively. (For now)
*/
enum qsock_type { QSOCK_TCP, QSOCK_UDP };
qd_t qsocket(enum qsock_type type);

qd_t qconnect(qfd_t fd, const struct qio_addr *addr);
qd_t qbind(qfd_t fd, const struct qio_addr *addr);
qd_t qlisten(qfd_t fd, uint32_t backlog);
qd_t qaccept(qfd_t fd, struct qio_addr *addr_out);

qd_t qsend(qfd_t fd, uint64_t n, const uint8_t buf[n]);
qd_t qrecv(qfd_t fd, uint64_t n, uint8_t buf[n]);

qd_t qshutdown(qfd_t fd);

/*
* %------------------%
* | QIO Address TYPE |
* %------------------%
* The qio_addr struct is used to when resolving hostnames for
* qconnect, qbind, and for storing client address upon qaccept.
*
* qio_addrfrom resolves the hostname with 'getaddrinfo' on posix.
*
* This can look something like:
*   struct qio_addr info;
*   qio_addrfrom("www.google.com", 443, &info)
*   qio_addrfrom("::1", 8080, &info)
*
* NOTE: This supports *only* IPv6. This is why localhost is "::1".
*
* This function returns non-zero on error. If successful, the address information
* of the resolved hostname and port is written to dst. This is sufficient for qconnect and qbind.
*/
int qio_addrfrom(const char *restrict hostname, uint16_t port,
                         struct qio_addr *dst);
```
Using this api, the messages defined in the IO module are *asynchronous*. They queue up IO operations which are batched
and run on a separate thread. While waiting for these IO operations to complete, other Gab fibers can run on the that
Gab thread instead. This is supported by a feature in Gab's native API, known as *yielding*.

### Yielding

The following is the type signature for a native block in Gab:
```c
typedef union gab_value_pair (*gab_native_f)(struct gab_triple, uint64_t argc,
                                             gab_value *argv,
                                             uintptr_t reentrant);
```
Two pieces are of note - the return value `union gab_value_pair`, and the last argument `reentrant`.
The `gab_value_pair` is used to indicate to the Gab runtime the status of your native function.
There are three options:
- Your function has completed, and the VM can continue executing bytecode. Use the macro `gab_union_cvalid()` to return this.
- Your function has panicked with an unrecoverable error. The VM must terminate execution of *all* fibers. Use the macro `gab_union_cinvalid()`, or the helper `gab_panicf`.
- Your function's work is *incomplete*, and you want to yield this fiber's time so that other fibers may continue. Use the macro `gab_union_ctimeout()`, and pass a non-zero 64-bit value. This will serve as the `reentrant`. The next time the Gab runtime chooses to schedule the fiber to run again, it will be called with this reentrant value.

This is where qio integrates with Gab, in the IO module. Here is a simplified example:
```c
union gab_value_pair async_socket_write(struct gab_triple gab, uint64_t argc, gab_value *argv, uintptr_t reentrant) {
    // If the reentrant is zero, this is our first time entering this function.
    if (!reentrant) {
        qd = qwrite(...);
        // Yield this fiber, with the qd as the reentrant.
        return gab_union_ctimeout(qd);
    }

    // At this point, we have a reentrant.

    // If the reentrant is done, 
    if (qd_status(reentrant)) {
        // Push result values onto the vm stack.
        gab_vmpush(gab, gab_ok);

        // Let the runtime know our call is over.
        return gab_union_cvalid(gab_nil);
    }

    // The operation isn't done yet, so simply yield again.
    return gab_union_ctimeout(qd);
}
```
And thats it! Now we have an async IO runtime which never blocks on IO. And the best part is that the user **never** knows its happening.
There is no function coloring or async/await, like in other languages. Simple!
## So what?
There is nothing unique or special-cased about the Gab's native IO module. It is implemented completely in user-land, with the same cgab library features that other
native modules would have access to. If *you* wanted to implement an IO module on top of libuv instead, you could! Gab's users wouldn't know the difference.

This is a fundamental philosophy of Gab's design. Native modules should be first class - native module authors should feel empowered to write highly efficient, non-blocking native functions without pulling their hair out.
