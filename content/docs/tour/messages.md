---
title: Messages
weight: 1
---

In most languages, control flow is driven by keywords: `if`, `for`, `while`, `switch`. Gab has none of these. Instead, **everything** is accomplished by sending messages to values.

If you've used Ruby or Smalltalk, this will feel familiar. If you haven't, don't worry — it's a simple idea with surprisingly deep consequences.

## Sending a Message

You send a message to a value using dot syntax:

```gab
'hello'.println
# => hello

['cat', 'dog', 'bird'].len
# => 3
```

The value on the left receives the message on the right. The message may produce a result, which you can immediately send another message to. This is called **chaining**:

```gab
['Hello', ' ', 'world!'].join.println
# => Hello world!
```

## Two Forms of Message Send

There are exactly two kinds of message send in Gab.

A **named send** is a `.` followed by one or more letters, underscores, or numbers:

```gab
'hello'.println
['cat', 'dog', 'bird'].len
```

An **operator send** uses a sequence of operator characters (`+`, `-`, `*`, `/`, `<`, `>`, `!`, `<!`, and others):

```gab
10 + 5      # => 15
channel <! 'value'
```

That's the complete syntax for invoking behaviour. There is no special function-call form, no keywords for control flow — only these two kinds of send.

## Messages with Arguments

Some messages take arguments. Arguments are passed inside parentheses, after the message name:

```gab
'Hello, $!'.sprintf('world').println
# => Hello, world
```

Here, `sprintf` is a message sent to the string `'Hello, $!'`. It replaces each `$` in the string with the corresponding argument. The result is then sent the `println` message.

You can pass multiple arguments by separating them with commas:

```gab
result = Strings.make('Hello', ', ', 'world!')
result.println
# => Hello, world!
```

## Defining a Message

Message names are **message values**, written with a trailing colon: `greet:`, `println:`, `def:`. The colon is part of the value itself.

You define a new message by sending `def:` to a message value:

```gab
greet: .def (Strings.t, () => do
  'Hello, $!!'.sprintf(self).println
end)

'Alice'.greet
# => Hello, Alice!
```

`def:` takes two arguments: the **receiver type** and a **block** containing the implementation. Here, `Strings.t` is the conventional way to refer to the string type — it is a message sent to the `Strings` module that returns the type upon which new string messages should be defined. Using `Strings.t` rather than a bare type name is a convention you'll see throughout Gab's standard library, and one you should follow in your own modules.

Inside the block, `self` refers to the value that received the message.

Message definitions are **specializations** — the same message name can have completely different implementations depending on the type of the receiver. This is how Gab achieves polymorphism without classes or interfaces. More on this in the [Records & Shapes](/docs/tour/records-and-shapes) section.

## Control Flow via Messages

Because Gab has no `if` keyword, branching is done by sending messages. Boolean values respond to messages like `then:` and `else:`:

```gab
age = 20

(age > 18)
  .then(() => 'You may enter.'.println)
  .else(() => 'Come back in a few years.'.println)
```

At first this looks unfamiliar, but it's the same idea: send a message to a value (the boolean result of `age > 18`), and pass blocks as arguments for each branch. The boolean decides which block to invoke — which it does by sending it the empty message, `.`.

This means branching, looping, and every other form of control flow are just messages — there's nothing special about them syntactically.

## Why Messages?

Constraining the language to a single dispatch mechanism is a deliberate trade. You give up some familiarity, and in return you get:

- **Consistency.** There's one way to invoke behaviour. No need to distinguish between method calls, function calls, operators, and special forms.
- **Extensibility.** You can define new messages for any type, including built-in types, without modifying their source.
- **Performance.** With a single dispatch path, the runtime can focus all optimization work on making message sends fast.
