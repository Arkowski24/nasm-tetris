# NASM Tetris

Unofficial Tetris clone for DOS, written purely in NASM Assembly.

![Game Screenshot](http://i.imgur.com/IrWaM49.png)

## Run Instruction
The game is a single .exe file, available in /bin subdirectory.

1. Download and install [DOSBox](https://www.dosbox.com/).
2. Mount project directory.
```
MOUNT C <path to project root>
```
3. Switch to C drive.
```
C:
```
4. Run program.
```
bin\tetris
```

## Controls
| Key    | Action                   |
| ------ | ------------------------ |
| A      | Move Left                |
| D      | Move Right               |
| S      | Drop: Soft               |
| Q      | Rotate Clockwise         |
| E      | Rotate Counter-Clockwise |

## Build Instruction
1. Obtain [NASM](https://www.nasm.us/) and a suitable linker.
2. Build .obj file.
```
nasm -f obj -o teris.obj
```
3. Link .obj file using linker of your choice.
