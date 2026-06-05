### run
```gab
ui:.run: (platform gui: | tui:, events Channel, frames Channel) :: ()
```

  Begin running an application.

  The platform argument defines how the application renders.
  - `gui:` Render in a new, native operating system window
  - `tui:` Render in the terminal

  The *events* and *frames* arguments are the entry/exit points for interacting with the running app.

  Every frame, a new event will arrive on the *events* channel. For more on events, see `ui\event`.

  It is the program's task to pull events off the `events` channel, process them, and put corresponding views onto the `frames` channel.
  
  A *view* is a data structure which describes the layout of the app. The `ui` library takes each view off the `frames` channel, walks the
  data structure, and renders a new frame. The cycle then repeats.

  For more information on views, see `ui\view`.
  

### event
```gab
predicate:alt:{ mouse predicate:cat:{ kind mouse, button predicate:any:[ left, right ]:, target predicate:message: }:, key predicate:cat:{ kind key, key predicate\string:, val predicate\int:, pressed predicate\boolean: }:, tick predicate:cat:{ kind tick, tick tick, hovered predicate:message: }: }:
```

  A *ui\event* is a tuple of values describing some user interaction, or simply the passage of time.
  

### component
```gab
predicate:alt:{ text predicate:pat:{ kind text:, opts predicate\record: }:, rect predicate:pat:{ kind rect:, opts predicate\record: }:, img predicate:pat:{ kind img:, opts predicate\record: }:, box predicate:pat:{ kind box:, opts predicate\record:, children ui\view: }: }:
```

  A component is UI element, drawable to the screen.
  

### view
```gab
List[ui\component:]
```

  A list of UI components.
  
