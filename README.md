# outsiders.vim

Move the file open in your current buffer to a vim instance in an adjacent tmux pane.

Think of it as a way to fork and merge Vim instances within tmux.

## Features

- Move files between Vim instances spatially (up, down, left, right)
- Automatically create a new tmux pane when moving into a window edge
- Preserves cursor position when moving files
- Focus follows the file

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):
```viml
Plug 'sturob/vim-outsiders'
```

Using [Vundle](https://github.com/VundleVim/Vundle.vim):
```viml
Plugin 'sturob/vim-outsiders'
```

## Usage

outsiders.vim provides four mappings in normal mode:

- `<Leader>mw` - Move file to pane above
- `<Leader>ms` - Move file to pane below
- `<Leader>ma` - Move file to pane on the left
- `<Leader>md` - Move file to pane on the right

1. If a pane exists in that direction:
   - With Vim: Opens the file in that Vim instance
   - With a shell: Launches Vim with the file
2. If no pane exists in that direction:
   - Creates a new pane + opens the file in a new Vim instance

## Configuration

The plugin works out of the box with default mappings. To change the mappings, add to your `.vimrc`:

```viml
nnoremap <silent> <Leader>mk :call outsiders#move_file('up')<CR>
nnoremap <silent> <Leader>mh :call outsiders#move_file('left')<CR>
nnoremap <silent> <Leader>mj :call outsiders#move_file('down')<CR>
nnoremap <silent> <Leader>ml :call outsiders#move_file('right')<CR>
```

## How It Works

outsiders.vim uses tmux commands to:
1. Detect existing panes and their positions
2. Create new panes when needed
3. Send commands to target panes to open files
4. Manage focus between panes

## License

MIT
