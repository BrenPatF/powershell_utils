# powershell_utils/MDUtils
<img src="png/mountains.png">

> Powershell Markdown Utility module

This module contains a utility that creates a combined markdown (MD) file from a set of constituent MD files listed in an input file. In markdown format section headings are specified by lines beginning with between 1 and 6 '#' characters followed by a space, with section level corresponding to the number of '#'s in the heading, and smaller number meaning higher level.

After merging the constituent files in order, the utility adds, after each heading, a link to any parent heading and a list of links to any child headings. These internal links form a tree structure that enables easy navigation for longer documents.

The heading hierarchy is defined by the simple rule that a heading is the child of the first higher level heading encountered when reading back up the file.

Usage is demonstrated by a simple example and in its use for the current README.

The module is tested using [The Math Function Unit Testing Design Pattern](https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html), with test results in HTML and text format included.

# In This README...