---
title: "Inspector-only variables in Unity3D using C#"
---

Sometimes you might want to create a component in Unity such that its data members behave differently in the inspector and in the code.
Let’s take a simple example:

> I want to create a Rubik’s cube game, so I define a game entity called Rubik. On this entity I have a component called “CubeDimensions”.
I wish to be able to dynamically define the cube size using inspector data (X, Y, Z) but no longer be able to change it from the inspector during debug mode. Additionally I don’t want my component to directly expose these variables since anyone can mess with them from the code – we want encapsulation here.

How to solve the above problem? I found quite a nice pattern that I think it would be useful.
First we create our `CubeDimensions.cs` and write its interface from the code point of view (we can even define an `ICubeDimensions` but we’ll not do that now).

{% highlight csharp linenos %}
public class CubeDimensions : MonoBehaviour 
{
    public Dimension3 Size { get; private set; }
}
{% endhighlight %}

This is pretty much all we need as far as the code goes. A way to retrieve the cube size without allowing anyone to alter it.

Now we need a way to set it from the inspector so we extend the class with three more data members:

{% highlight csharp linenos %}
public class CubeDimensions : MonoBehaviour 
{
    public Dimension3 Size { get; private set; }

    public int _inspectorSizeX;
    public int _inspectorSizeY;
    public int _inspectorSizeZ;

    private void InspectorStart()
    {
        Size = new Dimension3(_inspectorSizeX, _inspectorSizeY, _inspectorSizeZ);
    }
}
{% endhighlight %}

What happens now is that the only way to set the Size is at startup, when the game load. We get the next view in inspector window:

[![Dimension view from Unity inspector](/images/post_rubik_cube_dimensions.png)](/images/post_rubik_cube_dimensions.png)
**Unity inspector view of the cube dimensions**
{: class="post-image"}

And it is easily editable. How to use it? Take it, put it on your entity, edit it, and voila. We have encapsulation. Additionally you can even modify the way variables will look in the editor or change their labels and so on through the unity editor API. For now, we’re going to be happy with what we get.

#But wait? This sucks! You can still modify it after the game runs…

Oh, that. Yeah. We wouldn’t want anyone to start messing with those values and then wonder why nothing happens, right? So let’s create a nice method in our class called `InspectorUpdate`:

{% highlight csharp linenos %}
private void InspectorUpdate()
{
    if (_inspectorSizeX != Size.X ||
        _inspectorSizeY != Size.Y ||
        _inspectorSizeZ != Size.Z)
    {
        Debug.Log("Updating the dimension at runtime is not supported!");
        //Reverting to the used values.
        _inspectorSizeX = Size.X;
        _inspectorSizeY = Size.Y;
        _inspectorSizeZ = Size.Z;
    }
}
{% endhighlight %}

This method simply checks if the values are changed in which cases will log an error and revert to defaults. We can call `InspectorUpdate` from our update to trigger the check:

{% highlight csharp linenos %}
void Update()
{
    if (Debug.isDebugBuild)
        InspectorUpdate();
}

{% endhighlight %}

and we want to do that only in the debug build, to not add overhead otherwise. Notice that this isn't the best way to disable something in debug build, using custom defines also work. But it exemplifies the concept.

AWESOME isn’t it? To recap:

- We have our public property exposed as we want to expose it. *CHECK*

- We have a way to set up the script from unity itself. *CHECK*

- We prevent the user from modifying the variable when he is not supposed to do so? *CHECK*

* But Sebastian, you’ll say, this class has no logic and is already huge and ugly and I don’t know what happens there. I want my code to be beautiful.

Beauty. Yeah, this one kinda sucks now if I think about it. Good think c# has a nice trick for us :). What trick? *PARTIAL* freaking *CLASSES*!

We will create a new file called `CubeDimensions_UnityInspector.cs`

{% highlight csharp linenos %}
public partial class CubeDimensions : MonoBehaviour
{
    [SerializeField]
    private int _inspectorSizeX = 3;
    [SerializeField]
    private int _inspectorSizeY = 3;
    [SerializeField]
    private int _inspectorSizeZ = 3;
 
    private void InspectorStart()
    {
        Size = new Dimension3(_inspectorSizeX, _inspectorSizeY, _inspectorSizeZ);
    }
 
    private void InspectorUpdate()
    {
        if (!Debug.isDebugBuild)
            return;
 
        if (_inspectorSizeX != Size.X ||
            _inspectorSizeY != Size.Y ||
            _inspectorSizeZ != Size.Z)
        {
            Debug.Log("Updating the dimension at runtime is not supported!");
            //Reverting to the used values.
            _inspectorSizeX = Size.X;
            _inspectorSizeY = Size.Y;
            _inspectorSizeZ = Size.Z;
        }
    }
}
{% endhighlight %}

And modify `CubeDimensions.cs`

{% highlight csharp linenos %}
public partial class CubeDimensions : MonoBehaviour
{
 
    void Start()
    {
        InspectorStart();
    }
 
    void Update()
    {
        InspectorUpdate();
    }
 
    public Dimension3 Size { get; protected set; }
}
{% endhighlight %}

How beautiful. As you can see I also moved the `Start()` code to a specific initialize method and the debug check inside inspector update in order to keep everything as clean as possible in the main file. 

This is a very nice separation of concerns, and if you keep following the same guidelines it could be a very handy trick in making nice interface while still working with unity components. Future customization is possible, such as allowing to set the variables only under certain circumstances. The guidelines I’ve used:

- All editor variables will start with `_inspector[variable name here]`.

- Never call members starting with `_inspector` from your code (exception is `InspectorUpdate()`).

- Everything related to the inspector must reside in `[class name]_UnityInspector.cs`. 

- Never have logic inside the unity inspector file – it is used purely as a view on top of your class.

- Call `InspectorStart` and `InspectorUpdate` as the first line in `Start` and `Update`.

Not used here because of the code size, but I also document my variable stating the view it has so I won’t need later on to open UnityInspector files in order to check what is happening and who has a view an who doesn’t.

##Considerations:

There is a memory overhead when doing this so it might not be the best approach in all circumstances or you might want to rethink if your script will have thousand of instances in the game. But for most cases should be a nice way to provide clean interfaces in both Unity Inspector and code all that while encapsulating your data. 