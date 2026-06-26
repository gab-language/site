+++
date = '2026-06-25T19:22:23-04:00'
draft = false
title = 'Demo'
+++
## Why it matters
Gab is approaching a stable, usable point.
But as the language's author, I don't have a good perspective of how new users may feel.
In order to improve the experience for them, I need to put myself in their shoes.

>Eating your own dog food or "dogfooding" is the practice of using one's own products or services.[1] This can be a way for an organization to test its products in real-world usage using product management techniques. Hence dogfooding can act as quality control, and eventually a kind of testimonial advertising. Once in the market, dogfooding can demonstrate developers' confidence in their own products.[2][3]
> -Wikipedia

## Picking an Example
I want to maintain a small repository that new users can look to for an idea of how gab works.
Since I believe that gab's strength is in building native applications, I think the best way to demonstrate this
is with a small native gui app which does something useful and uses a range of gab's features.
For this case, I chose to implement a small wordle clone.

This is useful because:
- Some simple state/logic is required for managing guesses
- User input for key-strokes, special cases for enter/delete
- Requires embedding some static data, like a *valid words* list
- Shows off some of gab's best builtin modules and toolchain features

## Wait - did you say GUI?
Yes! GUI as in graphical! Gab ships with a `github.com/gab-language/cgab/ui` module which enables
programmers to develop *native gui applications*. Out of the box! It works like this:

First, create two channels. I like to call them `app` and `ev`
```gab
(app ev) := (Channels.make, Channels.make)
```
These are used to communicate with the UI fibers that do all the event-listening and rendering work for us.
We pass them into `run:` message like so:
```gab
UI
  .run(gui: ev app)
  .unwrap
```
Of course, we may fail to start the event/render fibers for any number of reasons. Unwrap the error so that we crash if we don't get back `ok:`.

>[!INFO]
>The `gui:` message tells the UI module to launch a new window and run in GUI mode. There are two other options,
>`tui:` and `hui:`. They render in the terminal and headlessly, respectively.

From this point on, our task is simple. Take *events* off the *ev* channel, process them however we need, and then put a new *view* on the *app* channel.
This is a perfect usecase for the `pipe:` message:

```gab
ev
  .pipe(
    app
    Transducers.take_until((e t key) :: do
      (e == key:) & (key == "escape")
    end)
    |> Transducers.reduce(model controller)
    |> Transducers.map(view))
```

The `pipe:` message is defined on the [seqable](/docs/protocols/seqable) protocol. By convention, protocols end in `-able`. Take a look at the [protocol](/docs/protocols) page to learn more about how these work.

In pseudocode, the `pipe:` message does the following:
```
for values in seqable:
    sinkable <! (values)
```
It uses the `seqable` protocol to iterate values from the source, and puts them into the `sinkable` with `<!`. 

Since `gab\channel` implements seqable and sinkable, we can just use them directly with the pipe message. This sets up a pipeline for us from `ev -> app`.

However, we need to do some data manipulation to maintain some state and translate events into views. This is where the Transducers come in!
The second argument to `pipe:` is an optinonal [Transduceable](/docs/protocols/transduceable). Transducers transform values in a sequence as they pass through.
The transducers themselves are composable - the `|>:` message is used to combine Transducers together. Lets look at the ones we use above:

- `take_until:`
- `reduce:`
- `map:`

First, we use the `take_until:` transducer to close the sequence once we see the `escape:` key event. This lets the user close our app!

Second, we use the `reduce:` transducer to keep track of our model's state as we receive events. *controller* is simply a block which takes a model and event, and returns a new model.
*model* is simply a record which contains all the state our app needs. *event* is a message which tells us what kind of event we're looking at - something like `key:`, `mouse:`, or `tick:`.

```gab
controller := (model event args*) :: do 
  model := event.dispatch(model args)
  model
end
```

Third, we use the `map:` transducer to transform our model into a list of components we can render. *view* is just a block that does this transformation.
We call out to some helper blocks to render the rows of our wordle game.

```gab
view := (model) :: [
  [
    box:
    {
      w\g: 1
      bg: Colors.bg
      align\x: center:
    }
    [
      [text: { size: SIZE * 2 bg: Colors.bg, fg: Colors.b } "gwordle"]
    ]
  ]
  [
    box: 
    {
      align\x: center:
      align\y: center:
      h\g: 1
      w\g: 1
      bg: Colors.bg
    }
    [
      model.guesses.map((g i) :: [box: { layout: horizontal: } HintRow.(model g i)])*
      current_guess.(model)*
      remaining.(model)*
    ]
  ]
]
```

There is some additional logic for handling guesses and events, and checking if the game is over, etc.
We did manage to cover the core of the architecture in this short article, and hopefully it helps you understand how
to structure your own apps in gab!

Here is the offical repo for [gwordle](https://github.com/gab-language/gwordle). There are some additional gems in this repo
if you're curious for more - like how to embed static data (like a word list) as module, and how to build cross-platform executables
in github actions and attach them to a release. Please download the game from the releases page and try it!

If you have gab installed, you can also install gwordle with

```bash
gab get github.com/gab-language/gwordle@0.1.0 gwordle@0.1.0

# Then, assuming you have gab/bin in your path
gwordle@0.1.0
```
