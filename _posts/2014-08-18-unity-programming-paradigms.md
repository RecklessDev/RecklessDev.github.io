---
title: "Unity programming paradigms"
---

###What would I gain if I read this article?

* Discover a rather simplistic description for Unity3D architecture.
* Learn to spot design concerns we should have while creating game components in Unity.
* Observe an Entity-Component-System approach that would allow us to create clean code in Unity.
* Learn an object oriented approach that would allow us to create highly decoupled components.

###What do I need to properly understand the concepts?
* You should be a bit familiar with Unity3D.
* Understand the basic concepts of an Entity-System-Component (ECS) paradigm.
* Understand OOP concepts (especially encapsulation).
* Be able to translate programming concepts into code (this article is not a coding tutorial).

###How can I find information on the prerequisite topics?
* For ECS I've learned a lot from [T-Machine](http://t-machine.org); you can also find a great deal of information on this [wiki page](http://entity-systems.wikidot.com)
* For Unity3D following the tutorials available on their site is the best way to learn
* For OOP there is no silver bullet; blood, tears and sweat is required to get the hang of it. Same for coding.

#Unity3D and Entity-System-Component

The main concepts in ECS paradigm are entities, systems, components ('doh) and messaging. The paradigm favors composition over inheritance and recommends creating highly decoupled components and systems. Entities should not directly communicate between each other but instead broadcast messages regarding their actions. Whoever is interested in those messages can just listen to them.

[![Diagram of an Entity](/images/post_conceptual_diagram_of_an_entity.png)](/images/post_conceptual_diagram_of_an_entity.png)
**Conceptual diagram of an Entity**
{: class="post-image"}

Systems also won't care about whatever is happening in the application; even more, they won't care what kind of entities exist. The only concern they have is to get sets of components they can process and apply their own algorithm on them. If a system is rendering 3D text above your NPCs it will just look for entities that have *Name* component and maybe *Transform* component in order to get the location and the text that has to be displayed.

[![Diagram of a System](/images/post_conceptual_diagram_of_a_system.png)](/images/post_conceptual_diagram_of_a_system.png)
**Conceptual diagram of a System**
{: class="post-image"}

You can see this in Unity as well. If you add a rigid body and a collider to your entity, suddenly the entity is affected by the physics engine. That is all that matters. And the physics engine couldn't care less if your entity is a player, a tree, a cloud or the camera game object as long as it has a rigid body and a collider.

However, if we talk about custom made entities, the story changes a bit. We, as users, can't really create systems inside Unity. I mean we could, but that is more like a hack since there is no proper architecture supporting this. Instead Unity promotes the idea of separating concerns. That is, have components that deal with a rather specific thing and which won't care (too much) about what else is happening around them.

I do believe that this slightly change from the original ECS paradigm is quite an improvement. It encourages us to really think about separation of concerns and abstraction which will really, in the end, result in modular code.

#Common Pitfalls to Watch for when Writing Code for Unity

In theory, all sounds nice. But in practice it is very easy to mess it up by creating dozens of unseen dependencies. Let's us the example of [Lil' Timmy](http://www.wowwiki.com/Lil_Timmy){:target="_blank"} that is creating the next amazing FPS where you can shoot Wallaby zombies with a gnome powered rocket launcher. And the first thing he modeled was the behavior of its rocket. He isn't really experimented but somehow he managed to do it.

If we would inspect his implementation we could see that his rocket has a *RocketDamage* component that sends a *RocketHit* message to whoever might be there to listen. So some other component has the *RocketHit* method to act when the rocket goes BOOM.

But wait... there's more! What Lil' Timmy didn't realized is that even after he added the *RocketHit* method, because of how messaging works, that method must always remain on the same entity: be it a parent entity or a child entity. Start paying attention to renames since something like this is easily breakable. No compile error if you mess it up. No warning. Nothing. Just that your rocket will do absolutely nothing whenever it hits something. Not fun to debug if that happens, but still, quite easy to catch. Maybe a bit annoying

Now, his rocket also has the need for a certain component called *EntityElementType*, which will decide if the damage done is *Fire*, *Ice* or *Nature*. Maybe you can feed the rocket launcher with burning gnomes and you get fire damage... who knows. But now he kind of needs the element type information and -- oh! -- how easy it is for him to just call *GetComponent*. Ah! -- of course, there is also have a *SpellCasting* component on a child entity because some weird development requirement asked the rocket to cast "fireballs" or "iceballs" or "nature-something" and -- oh! -- how easy it is to just call *GetComponentInParent*. Lastly, just before the release, a parent entity got a shiny new custom shader which is based on the element used, so then, once more, how easy it is to get the element type if you just call *GetComponentInChildren*.

The diagram below exemplifies the architecture.

[![Architecture from HELL](/images/post_architecture_from_hell.png)](/images/post_architecture_from_hell.png)
**Architecture from HELL *(no innocent bunnies were harmed)***
{: class="post-image"}

Yes, yes I know what you're thinking, it is a dumb example. That is correct, it is. But similar things happen in real life. Maybe with better naming and better reasons, but it happens.

It is insanely easy to get in such situations where these unseen constraints are introduced. You get Lil' Timmy game and decided to reuse the *SpellCasting* component? Well suddenly you realize you need to have a parent entity which provides the EntityElementType component. Either that, or you start to refactor.

Do you want to reuse the rocket? Bad luck, your rockets need a sibling component providing the ElementType. Things go even worse when the ElementType also depends on who knows what entities that are either siblings or to be found on parents, on child entities or if you are unlucky, on entities with a specific name or a specific tag. From the clean Entity-System-Component architecture to a mess made of arrows (and blood and sweat and swearing).

This is what happens when Lil' Timmy doesn't plan his work. Just imagine the whole mess when you add tag, name or location dependencies.

[![UML Diagram for Lil' Timmy's code](/images/post_stacked_houe_of_cards.jpg)](/images/post_stacked_houe_of_cards.jpg)
**UML Diagram for Lil' Timmy's code**
{: class="post-image"}

#Embracing: Clean Design Using Unity Architecture

Luckily, with a bit of attention and design the above mess can be avoided. Ideally we would have few to none of those dependencies. Each dependency not verified at compile time adds maintenance cost.

Before getting to see how OOP can help us here, assuming we still want to stay as close as possible to Unity architecture we can embrace few guidelines to help us, such as:

- **Components that are too coupled should be combined.**

Scattering all concepts in different components although there is no plan to reuse them will result in dependencies growing exponentially for no reason. Two components could be combined if there is no need to reuse one of them without the other. Extra attention should be payed to also follow [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle).

- **Components that need to communicate a lot should be linked either with [inspector-only data members](http://www.recklessdev.com/2014/07/inspector-only-variables-in-unity3d.html) either through a third class managing their relation.**

Doing hard links allows us to perform checks at run-time and is an explicit documentation of possible dependencies. The drawbacks is that we could potentially get too many public variables that needs to be set each time you want to use a certain component therefore is not really user-friendly. Still, it's a better practice than what Timmy did above. Also it's used in most Unity projects so others will be familiar with the concept.

- **Messaging should normally be avoided, but when used ensure that the dependency is thoroughly documented.**

Consider adding debugs checks and throwing errors whenever you can detect an anomaly, such as no one calling your message receiver when you expect to be called or the message is not received by anyone etc. But if possible, replace the messaging with [direct links](http://www.recklessdev.com/2014/07/inspector-only-variables-in-unity3d.html) between entities.

- **Avoid GetComponentInChildren(s) respectively GetComponentInParent(s).**

If an entity has other child entities and it does make sense semantically to be like this, getting components from parent(s) or children(s) could be OK. But even in those cases I would restrict the usage in retrieving only default Unity components (Transform, Rendering etc.). 

The main issue that appears when you extensively use these methods is that you prevent any structural refactoring to your prefabs / game objects and, once more, there are no compile time checks to announce you that you broke something. If you have a car, there is no reason to not have a chassis as a child entity, but if you have a wizard and its wand is a child entity, later on you might rethink that design and wish to remove the dependency. Maybe the wand should act on its own so it no longer makes sense to be a child of a wizard.

Like in messaging, whenever one of those methods fails make sure you throw a proper error message and explain clearly why this call is needed so later on can be easily fixed, if broken.

#Encapsulating: Clean Design Using OOP for Core Features

Although Unity is using ESC paradigm we can still make use of OOP concepts to create beautiful designs. This is not a completely different approach though, but merely a new tool in our game development toolbox that can be used along with ECS or Unity without breaking anything and without sacrificing readability.

With this approach, our main focus is abstraction. Basically we design thinking how to properly separate concerns, minimize dependencies and encapsulate implementation details in the scope of modules. We aim for separating the Model from the View (especially or maybe only for core features) and make heavy use of interfaces in order to control the communication.

Factories get the responsibility of properly instantiating stuff without leaking knowledge on how or from where are the objects coming. Interfaces will hide the model from the Unity components while still providing all the required functionality. Events will provide a way for the Model to receive information directly from the view without strongly coupling the two of them. Events basically replace the messaging.

[![UML Diagram for Lil' Timmy's code](/images/post_architecture_overview.png)](/images/post_architecture_overview.png)
**UML Diagram for Lil' Timmy's code**
{: class="post-image"}

This is a type of architecture that you don't really want to spread to a whole project but rather keep it as a *black-box* for specific features.

Let's say you want to implement a complicated mini-map system for an RPG. You could use such an architecture to model the mini-map system while not constraining yourself to do the same for every other part of the game. Dependencies are easily maintained, the feature is reusable in future projects regardless of their type (maybe a racing game needing a mini-map?) and changes can be done easier. We also have the advantage of mocking a lot of stuff using the interfaces and creating pertinent unit tests.

The Model would use interfaces from the communicating layer to get map information, current position, fog of war and maybe listen to some events triggered when something important happens (zoom in/out, click the mini-map, add markers etc).

The interface implementations are provided by the VIEW and are implemented either in Unity, either in similar Models but from other related features. This is a thing factories should take care of.

The Model outputs whatever data is processed using methods and events. The View (or, again, other similar models) will register to those events or call the right methods in order to properly react or use the computed information.

Ideally, putting a console window (or any other View & Controller) on top of the Model will allow our feature to work just as in Unity.

Now, this might look like an awesome thing, but like anything else, using it in excess will pretty much make everyone sick. There are lots of benefits when modeling core features of our games that really contain a lot of important logic like this but no so many for modeling trivial components as such.

As an example, in my [Match 3 game concept](http://www.recklessdev.com/2014/07/match-3-progress-refactoring-animations.html) I am using this type or architecture to model the game board and its entities. Selection, combinations, spawning and pretty much anything related to game board is kept in a model, separately from Unity. Animations, user interaction, GUI, spell effects, NPCs and so on are kept in Unity (as of now - this might change in the future as stuff gets added).

That architecture now allows me to easily test, modify or completely replace sensitive features of the game with little overhead and less chances of introducing bugs. If I get that code, dump it in a C# project and put a windows forms on top of it, it will work just the same.

Works the other way around too: modifying only the unity project lets me create virtually any game using such a game board (ex: a candy-crush type of game). The overhead paid to create and maintain this architecture for the game board is relatively small compared to the benefits I get. 

Does it work for all projects or all features? Probably not. Are there cases where this can indeed bring more benefits than drawbacks? Definitely, I am more than sure. For me, this is a useful tool to keep in my *Unity toolbox*.

Since this is such a complex subject most likely many other posts will follow where I will discuss concerns raised here, but for now I believe I managed to pretty much cover the main idea. If you have questions or counterarguments I will be more than happy to hear them.

Feel free to leave a comment or directly contact me at <a href="mailto:sebastian.gorobievschi@recklessdev.com">sebastian.gorobievschi@recklessdev.com</a>
