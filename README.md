# vim-outsiders

A Vim plugin for spatially moving files between Vim instances in tmux panes.

## Overview

vim-outsiders lets you quickly move your current file to adjacent tmux panes using spatial navigation (up, down, left, right). If a pane exists in the target direction with Vim or a shell running, it will open the file there. If there's no pane in that direction, it creates a new pane and opens the file in it.

Think of it as "pushing" your current file outside its current Vim instance into another one.

## Features

- Move files between Vim instances using spatial directions (up, down, left, right)
- Automatically creates new tmux panes when moving to an edge
- Preserves cursor position when moving files
- Works with both existing Vim instances and shell panes
- Focus follows the file, making the workflow smooth and intuitive

## Requirements

- Vim 8.0+
- tmux 2.0+
- A Unix-like environment (Linux, macOS)

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):
```viml
Plug 'your-username/vim-outsiders'
```

Using [Vundle](https://github.com/VundleVim/Vundle.vim):
```viml
Plugin 'your-username/vim-outsiders'
```

## Usage

vim-outsiders provides four mappings in normal mode:

- `<Leader>mw` - Move file to pane above
- `<Leader>ms` - Move file to pane below
- `<Leader>ma` - Move file to pane on the left
- `<Leader>md` - Move file to pane on the right

When you use these mappings:
1. If a pane exists in that direction:
   - With Vim: Opens the file in that Vim instance
   - With a shell: Launches Vim with the file
2. If no pane exists in that direction:
   - Creates a new pane
   - Opens the file in a new Vim instance
3. In all cases:
   - Cursor position is preserved
   - Focus follows the file
   - The file is closed in the original pane

## Configuration

The plugin works out of the box with default mappings. If you want to change the mappings, add to your `.vimrc`:

```viml
" Example of custom mappings
nnoremap <Leader>mu :call <SID>MoveFile('up')<CR>
nnoremap <Leader>mj :call <SID>MoveFile('down')<CR>
nnoremap <Leader>mh :call <SID>MoveFile('left')<CR>
nnoremap <Leader>ml :call <SID>MoveFile('right')<CR>
```

## How It Works

vim-outsiders uses tmux commands to:
1. Detect existing panes and their positions
2. Create new panes when needed
3. Send commands to target panes to open files
4. Manage focus between panes

The plugin is designed to work with tmux's spatial layout system, making it feel natural and intuitive.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT
