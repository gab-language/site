---
title:
toc: false
sidebar:
    exclude: true
---

{{< index/hero
    title="A modern scripting language for the world we *compute* in."
    subtitle="gab is a dynamic language. Parallelism, asynchrony, dependency management, deployment, and performance are core elements of gab's coherent vision and design."
>}}

{{< cards cols="2">}}
  {{< card link="docs/installation" title="Install gab" icon="download" >}}
  {{< card link="docs/gabonomicon" title="gabonomicon" icon="book-open" >}}
{{< /cards >}}

{{< /index/hero >}}

{{< index/features >}}

{{< index/feature-card title="Parallel" icon="circle-stack" >}}
gab's runtime is multi-threaded by design. All datatypes in gab are immutable, and therefore can be trivially sent to and from threads without any manual synchronization.
gab provides the building blocks for the same model which inspires golang, erlang, and many others.

```gab
ch := Channels.make

Fibers.make () :: do
    ch <! "Hello"
    ch <! "world"
end

msg := Strings.make(ch >!, " ", ch >!)

msg.println
```

{{< /index/feature-card >}}

{{< index/feature-card title="Asynchronous" icon="arrow-path-rounded-square" >}}
gab's builtin `Io` module is completely asynchronous. Your gab program will *never* block an os thread waiting on i/o. (And you can forget about that **async** keyword while you're at it)
```gab
# Launch many fibers to perform some background work.
launch_workers.()

# Work is done on *this thread* for other fibers while waiting for the write to finish.
file.write(a_really_long_binary)

'Hurray!'.println
```
{{< /index/feature-card >}}

{{< index/feature-card title="Distribute & Deploy" icon="rocket-launch">}}
gab includes the `gab build` command, which creates bundled packages or apps. Bundled apps can be distributed as a single binary, and can be built *for* any platform *from* any other!
```bash
# Build your app in one command for any target
gab build -t aarch64-windows-gnu my_app@1.0.0 < dependencies
# Distrubute the stand-alone executable 'my_app@1.0.0-cgab-0.1.5-aarch64-windows-gnu.exe'

# Build your package into a distributable bundle in one command, also for any target
gab build -t aarch64-windows-gnu -m github.com/me/my_package@0.1.0
# Distrubute the stand-alone bundle 'cgab-0.1.5-aarch64-windows-gnu'
```
{{< /index/feature-card >}}

{{< index/feature-card title="Manage Dependencies" icon="cube">}}
gab ships with a simple `gab get` command, making it trivial to download packages and apps from the command line. (You also use this to download and manage your gab versions).
```bash
# Download the demo wordle app
gab get github.com/gab-language/gwordle@0.1.1 gwordle@0.1.1

# Run it!
./gwordle@0.1.1
```
gab keeps separate packages and apps based on their versions, as well as the *gab* version they depend on. This allows you to have different versions of the same package/app, targeting different versions of cgab, and they all coexist happily.
{{< /index/feature-card >}}

{{< index/feature-card title="Batteries Included" icon="battery-100">}}
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
{{< /index/feature-card >}}

{{< /index/features >}}
