# movement-demo
 go with the flow
 ### Compliance with #resources:community-tutorials 
- [Post complies with category points 1, 3, 4](https://devforum.roblox.com/t/about-the-community-tutorials-category/27617)

---
I have been approached by a sizable number of developers regarding my [dashing post](https://devforum.roblox.com/t/whats-the-best-way-create-a-dashing-script/677418/18?u=overflowed)
It would be a disservice to these developers by providing supplementary info/tweaks/fixes to code that's nearly 2 years old

###### As I am still learning the hokey-pokey of Luau (: operators, etc). I apologize in advance for any confusion or misinformation that is imparted from this tutorial. If there are any corrections to be made to the definitions please let me know.
###### All code written in Visual Studio and synced with Rojo, highly recommended to use for developers

### Cross-platform compatibility

In terms of services, I use both [ContextActionService](https://create.roblox.com/docs/reference/engine/classes/ContextActionService) and [UserInputService](https://create.roblox.com/docs/reference/engine/classes/UserInputService)
There are, however, some "ghetto" workarounds that I use
(such as the mobile jump button .`Activated` event firing when the input ends [makes zero sense])