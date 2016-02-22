The point of this directory is to try a version of the elm implementation that
cleanly separates the data model from the view model. For example, it removes
the "hidden" field from the Simulation structure since that parameter only
exists to facilitate the view.

While this kind of separation is, of course, doable, in the end it seems quite a
bit over-engineered and obfuscating for a project like this. You end up with
parallel data structures and the pain that entails when actually using them.
More to the point, it doesn't seem to make things any better from a development
point of view. Perhaps it would make more sense on a larger project, and perhaps
there are patterns I could apply which would make this all simpler. But for now,
I'm abandoning this line of development.
