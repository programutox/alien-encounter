# Alien Encounter

> Shoot the right alien to progress!

## Why I made this game

I created a game called [Where Impostor](https://github.com/programutox/Where-Impostor), which was a simple shooter.
I wanted to remake it in a more serious and fun way, with animations, more mechanics, etc.

I started created the remake with the name "Criminal Alien", and programmed it in C++ with raylib. It worked well until I got strange crashes.
I tried to implement it in other languages (Rust & macroquad, JS & kaboomjs), but I was losing motivation. I didn't know which language to pick. Then I discovered V.

## Why V

[V](https://github.com/vlang/v) is a language which has a simple syntax (similar to Go), but with good toppings (immutability by default, no null) and great performance. It also includes a package manager and a formatter. I created some basic projects to learn quickly.

### Issues met with V

- Not many libraries
- Memory leaks. 

Even when unloading all the assets correctly I got memory leaks.

When writing a basic code like this :

```v
module main

import irishgreencitrus.raylibv as rl

const (
	screen_width  = 800
	screen_height = 450
)

fn main() {
	rl.init_window(screen_width, screen_height, 'Basic window'.str)
	defer rl.close_window()

	for !rl.window_should_close() {
		rl.begin_drawing()
		rl.clear_background(rl.raywhite)
		rl.draw_text('Nice window'.str, 190, 200, 20, rl.black)
		rl.end_drawing()
	}
}
```

There were memory leaks, unless I used the `-autofree` feature, which places free functions and the end of the scope at compile-time.
However, I could not use that on my game, since it used OOP. It means that the assets would be freed at the end of the constructor.

## Why Lua

I didn't know which language to pick, and to be honest I already tried to learn Lua twice, but I didn't find it appealing.
I started to read Love2D tutorials, and found it quite interesting.

### Pros

- I added better names to functions and classes.
- I had to reflect about how to construct the logic of the game as Love2D takes a more functional approach rather than OOP.
- The Lua Vscode extension works very well (relevant snippets, warns unchecked nil variables...)

### Cons

- Many times I tried to index an attribute that didn't exist, and Lua yells at you only when it realizes the value is nil.
- Division returns a number (i.e a float), so you get weird behaviors with positions if you don't round the values down. Lua supports the // operator (like Python, it returns an integer), but LuaJIT doesn't. Therefore I had to stick with math.floor function. 

## What's next ?

I will certainly use [Moonscript](https://moonscript.org/), which is a more programmer friendly language that compiles into Lua.
Also, I think I'll use game states (a State interface and gamestate objects) instead of a state variable with string values. Refactoring now would be too time-consuming and error-prone.
