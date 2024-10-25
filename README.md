# outsiders.vim

'Move' the file you are editing to an adjacent tmux pane.

Think of it as a way to fork and merge Vim instances.

## Features

- Move files between Vim instances using spatial directions (up, down, left, right)
- Automatically creates new tmux panes when attempting to move to a window edge
- Preserves cursor position when moving files
- Focus follows the file, making the workflow smooth and intuitive

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

## License

MIT
