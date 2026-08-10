---
title:
---

# Build cross-platform native apps in an afternoon.
gab is a dynamic, general-purpose scripting language designed and built from scratch. It is intenionally minimal, while providing the programmer with a core set of composable tools to build scalable, parallel applications.

## Batteries Included
gab's standard library ships with a growing number of useful modules. Beyond those you'd expect like `Json` or `Io`, gab includes `Ui`: an elm-inspired module for building cross platform graphical/terminal applications.

```gab
Ui := 'github.com/gab-language/cgab@0.1.4' .use 'cui'

(events, app) := (Channels.make, Channels.make)

Ui.run(gui: events app)
  .unwrap

events
  .pipe(
    app,
    Streams.take_until((e t key) :: do
      (e == key:) & ((key == "escape") | (key == "q"))
    end)
    |> Streams.reduce(
      model
      (app, args*) :: app.app\controller(args*))
    |> Streams.map(app :: app.app\view)
  )
```

## Convenient Cross Platform
gab's packaging and bundling system makes distributing your application trivial. In one `gab build` command, produce native binaries for *any* supported platform.
```bash
# Build native binaries  for *any* target using the `build` command. 
gab build my_app -t aarch64-macos-none < dependencies
# gab: * Created application my_app-cgab-0.1.4-aarch64-macos-none.exe (8.2 mb).

# Download packages and binaries using the `get` command.
gab@0.1.3 get github.com/gab-language/gwordle@0.1.0 gwordle@0.1.0
./gwordle@0.1.0
# Play wordle!
```

## Simple
gab's syntax is minimal - learn the whole language in an afternoon.

```gab
welcome := ['Hello', ' ', 'world!']
welcome.join.println
# :: Hello world!
```

## Parallel

Gab's runtime is built on units of execution fibers. Fibers are lightweight and far cheaper than OS threads - make as many as you like. Gab will schedule them across all your cores, and run them in parallel.

```gab
print_chan := Channels.make

Ranges.make(0, 10000).each i :: do
  Fibers.make () :: do
    print_chan <! 'Hello from fiber $!'.sprintf(i)
  end
end

print_chan.each (msg) :: msg.println
```

{{< cards >}}
  {{< card link="docs/installation" title="Install Gab" icon="download" >}}
  {{< card link="docs/gabonomicon" title="Gabonomicon" icon="book-open" >}}
{{< /cards >}}
