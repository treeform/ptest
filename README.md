# Print-Testing

You debug with print statements? Why don't you also test with them?

Idea behind print testing is that you can run a script that runs through major uses of the library. Then the output is compared to the previous output, if they don't match that's an error. That’s it.

I never liked writing unit tests, probably because it always felt really boring. It felt like I am just retyping the output over and over again. It made refactoring really hard where I change something and then I think of the 100s of little boring changes I now need to make in the tests. It made me not want to refactor and it made me not want to write tests. Do you feel this way?

Story time! So I was working on a compiler that converts stuff to SQL. Every time I made a change I had to change many of my tests. This was true even for minor things. Things that did not matter much. Rename a token here, rename a node there, and WHAM! All of a sudden I need to change the tests in hundreds of places. I made a small API change, I refactored some stuff. WHAM! 100s of changes in tests! It was very boring needless work. After looking at how some other people do compiler testing I discovered print-testing. I don’t know what its called exactly, but I call it print-testing as its similar to print-debugging.

I explained this method to a friend, and he went “well it could work” but there is this and that problem with it. It's too easy to forget or be lazy. But then two weeks later he comes to me having tried it and goes: “Hey your thing actually works! I like this method.” You should try it too!

This is how it works:

Imagine a simple file that just runs through the motions doing some sort of work. And we just print the steps as it goes along. Then you commit the output of your print-testing to git only when you like how it looks. That's it.

For example something like this, that tests simple vec2 type:

```
import vmath

echo "--- basic vector vec2"
var a = vec2(1, 2)
var b = vec2(7, 6)
var n = 13.7
echo a + b
echo a - b
echo a * n
echo a / n
a += b
echo a
a -= b
echo a
a *= n
echo a
a /= n
echo a
```

So then you run and pipe the output into a text file which looks like this:

```
--- basic vector vec2
(8.0000, 8.0000)
(-6.0000, -4.0000)
(13.7000, 27.4000)
(0.0730, 0.1460)
(8.0000, 8.0000)
(1.0000, 2.0000)
(13.7000, 27.4000)
(1.0000, 2.0000)
```

Now the important step is to commit the output file to git. Just like the test file the output file is basically code now. It’s in git now!

So now every time to run the test, you pipe the output and then git diff it.

```
nim c -r vmathtest.nim > vmathtest.txt; git diff vmathtest.txt
```

Now the magic part comes: Any time the files changes you will see red or green in your diff.
Here is where you decide if you like the changes, or maybe need to dig a little deeper to change stuff. Go ahead iterate. Run it again and again. After you are happy with the changes all you have to do is commit the output file. Now you see the changes to tests a lot easier. Reviewers and future you see the changes easier too!

It's that simple!

Yes, you could write the test as a bunch of asserts like this:

```
import vmath

sute:
  test: "basic vector vec2":
    var a = vec2(1, 2)
    var b = vec2(7, 6)
    var n = 13.7
    assert a + b == vec2(8.0000, 8.0000)
    assert a - b == vec2(-6.0000, -4.0000)
    assert a * n == vec2(13.7000, 27.4000)
    assert a / n == vec2(8.0000, 8.0000)
    a += b
    assert a == vec2(8.0000, 8.0000)
    a -= b
    assert a == vec2(1.0000, 2.0000)
    a *= n
    assert a == vec2(13.7000, 27.4000)
    a /= n
    assert a == vec2(1.0000, 2.0000)
```


I was basically just copy pasting the output and got bored after 4 lines. What should I call it the suit and test? Should I break this out into a bunch of small little tests? All these things just descent on you. I don’t really care about any of this!

I really prefer just writing straight no nonsense print statements.

Now for something big like refactoring! Say I want to change everything from float point to fixed point (Fixed point is when you use integers as floats). This is a big refactor, it will change all the tests! I would have to change every assert line! That is a ton of work! But not with the print-testing method. You just kind of approve the changes and commit. With the print-testing approach I was done in minutes with a large math library with many many tests.


Hey look it even highlight the characters where the test is different!

All of the numbers are almost the same, it's just that fixed point has less digits and they are less accurate. In a real world I might have to modify tons of lines. Here I just kind of “approve” the changes to the test output them by committing.

You can think of it as abstracting your assets into a different file, so that it can be reviewed more easier there. Before you had an “assert-thing” and now you have “print” and the “thing” is in a different file. It does not feel like a huge change. Oh but it is! Now you have tools, like git and graphical diff to help you along!

Compilers and Simulations

This test system might not be great in all cases, but the cases I have are compilers and simulations this makes the perfect senses. In simulation and compiler a small change can have large scale changes. Change a name of a node and then everything changes. Change the map generator and everything changes. I don’t want to be stuck copying outputs back and forth. I can see these changes and just approve them or dig into them if they puzzle me.

Print-testing just frees me to write more tests. In my current project I have 1:8 test coverage. Where each line is tested by 8 lines of tests either in code file or the output file. That is a ton. I would never be able to write this much test lines by hand, I would have died of boredom. But with this I can kind of cheat and automatically generate the test lines. And I can always see how stuff changes with tools I already use git and graphical diff.

Debugging

Here they help me a ton as well. Many of the times you change something and test fails. The output is puzzling. But with this method you also see all the other change as well. With a single example the bug might not be clear. But with a couple of examples I can tell right a way what is going on. For example the output is null. Why is it null from a single test its not clear. But then you see tons of other tests are null now too, probably just forgot to initialize some thing very early on.

Another cool thing there are print statements everywhere the output is a lot easier to follow. Say there is a simulation with space ships, you can see them live and die. I can just kind of walk over what the simulation is doing. Instead of getting a cryptic ship not found I can see that it died early on because it had health set to zero. It's all there in the output!

It is just like print-debugging but in a controllable and reproducible way. I find myself I am doing more and more debugging in this way.

Organization

Because this is not in some unit tests framework thing, I can organize code how I want. I can have tons of helper functions that do their own tests. I can have function and for loops. I don’t have to be constrained to the suit, setup, run test, tare down. Real world is more complex then this. Real stuff never quite fits this model. Just don’t! Write how it makes sense to decompose the problem. Reduce that boilerplate copy-pasta in your tests!

Output you want

Something I have also done is editing the output file and put my own output and committed it in. Say I want to the method to return 4 not 5. I can just add that write 5 in and commit. Now it would be red while I debug. It would only pass when there is no diff. Merge conflict? Just fix the main file and generate the output text file. Done.

Complacency

Could you get lazy and just commit the changes without looking at them closely? Yeah you could. And it has happen to me and it will happen to you. You have to debug your tests too. But at-least in my case if I was too lazy or to tired to check the output of a print-testing I would probably would just not have written the standard unit-test in the first place. It is kind of like a game to trick my lazy self write more test.

Historical stuff

Print-testing is related to Characterization Test or Golden Master Testing. I never heard about it before. It can’t be very common. This type of testing is more about wrapping legacy system in tests rather than relying on a simple text file, git and diff. It's not what you do, but how and why you do it. But it is related.

You should try it.

Are you lazy? Do you hate writing tests? Try this method! Tell me how it works and what you discover.




