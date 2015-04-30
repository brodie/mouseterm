MouseTerm
=========

MouseTerm is a [SIMBL][1] plugin for Mac OS X's [Terminal.app][2] that
passes mouse events to the terminal, allowing you to use mouse
shortcuts within applications that support them.

To get started, first install [SIMBL][1] (MouseTerm won't work without
it!). Once you've done that, open the `.dmg` file, run `Install`, and
restart Terminal.app. To uninstall, run `Uninstall` from the `.dmg`.

[1]: http://www.culater.net/software/SIMBL/SIMBL.php
[2]: http://www.apple.com/macosx/technology/unix.html


Download
--------

* [MouseTerm.dmg][3] (116 KB, requires Leopard or newer)

[3]: http://bitheap.org/mouseterm/MouseTerm.dmg


Status
------

MouseTerm is currently beta quality software. It's feature complete,
but still needs testing.

What works:

* Mouse button reporting.
* Mouse scroll wheel reporting.
* Simulated mouse wheel scrolling for programs like `less` (i.e. any
  fullscreen program that uses [application cursor key mode][4]).
* Terminal profile integration (with preferences dialog).

What's being worked on:

* A nicer preferences dialog.

[4]: http://the.earth.li/~sgtatham/putty/0.60/htmldoc/Chapter4.html#config-appcursor


Frequently Asked Questions
--------------------------

> What programs can I use the mouse in?

This varies widely and depends on the specific program. `less`,
[Emacs][5], and [Vim][6] are good places to test out mouse reporting.

> How do I disable mouse reporting temporarily?

Use "Send Mouse Events" in the Shell menu.

> How do I configure mouse reporting on a profile basis?

In the preferences dialog under Settings, you can configure terminal
profiles. Select the profile you want to configure, go to the Keyboard
section, and click the "Mouse..." button to change what mouse buttons
are reported to programs in the terminal.

> How do I enable mouse reporting in Vim?

To enable the mouse for all modes add the following to your `~/.vimrc`
file:

    if has("mouse")
        set mouse=a
    endif

Run `:help mouse` for more information and other possible values.

> What about enabling it in Emacs?

By default MouseTerm will use simulated mouse wheel scrolling in
Emacs. To enable terminal mouse support, add this to your `~/.emacs`
file:

    (unless window-system
      (xterm-mouse-mode 1)
      (global-set-key [mouse-4] '(lambda ()
                                   (interactive)
                                   (scroll-down 1)))
      (global-set-key [mouse-5] '(lambda ()
                                   (interactive)
                                   (scroll-up 1))))

[5]: http://www.gnu.org/software/emacs/
[6]: http://www.vim.org/


Development
-----------

Download the official development repository using [Git][7]:

    git clone git://github.com/brodie/mouseterm.git

Run `make` to compile the plugin, and `make install` to install it
into your home directory's SIMBL plugins folder. `make test` will
install the plugin and run a second instance of Terminal.app for
testing.

Visit [GitHub][8] if you'd like to fork the project, watch for new
changes, or report issues.

[JRSwizzle][9] and some mouse reporting code from [iTerm][10] are used
in MouseTerm. [Ragel][11] is used for parsing control codes.

[7]: http://git-scm.org/
[8]: http://github.com/brodie/mouseterm
[9]: https://github.com/rentzsch/jrswizzle
[10]: http://iterm.sourceforge.net/
[11]: http://www.complang.org/ragel/


Contact
-------

Contact information can be found on my site, [brodierao.com][12].

Thanks to [Tom Feist][13] and [Scott Kroll][14] for their
contributions.

[12]: http://brodierao.com/
[13]: http://github.com/shabble
[14]: http://github.com/skroll
