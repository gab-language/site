+++
date = '2025-02-07T18:33:11-05:00'
title = 'Messages'
weight = 2
+++
### Message Sends
The only way to *do* anything is by *sending a message to a value*.
```gab
"Hello world!" .println # => Hello world!
```
Earlier we saw message literals, which look like this:
```gab
println:
```

Now we've seen a message *send*, which is like calling a method or function:
```gab
any_value .println
```

Message literals can also respond to messages!
```gab
my_message: .println # => my_message:
```
In fact, this is how new messages are defined in Gab!
```gab
my_message:.def!(
    myType,
    () => do
        self.name.println
    end)
```

Messages *themselves* respond to the `def!:` message by adding a new implementation for the given type(s).
There are several other messages for defining new implementations, which gab refers to as **specializations**.
```gab
# Define multiple specializations for one message, conveniently
my_message: .defcase! {
    nil:  () => "I was nil!"
    true: () => "I was true!"
    none: "I was none!" # Values alone can also serve as a specialization.
}

# Define the same specializations for multiple types, conveniently
[ myType ] .defmodule! {
    message_one: () => "Sending message one"
    message_two: () => "Sending message two"
}
```
### Message Values
We've seen message values before, they are identifiers that end in a colon`:`.
They're useful for singleton values - and in fact, Gab implements booleans and nil using messages. More on in this in later chapters!
Gab also uses message values to implement results or optionals.
Since Gab has multiple return values, sends that can error often return multiple values like this:
```gab
(ok file) = Io.open('Maybe_Exists.txt')

(ok file) # => If the file exists  (ok: <gab\io\stream ...>)
          # => If the file doesn't (err: "File not found")
```
