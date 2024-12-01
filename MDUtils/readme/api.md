## API
```powershell
Import-Module MDUtils
```

!### Merge-LinkMDFiles

```powershell
Merge-LinkMDFiles($headingsInpFile, $mergedOutFile)
```

This function constructs a markdown file, `$mergedOutFile`, by merging constituent files listed in the input  file, `$headingsInpFile`. After merging the constituent files, it constructs internal URLs linking parent and child headings. After each heading line, a link is added to any parent heading line, and a set of links to any child headings.

A heading line in markdown is a line beginning with between 1 and 6 '#' characters followed by a space, with section level corresponding to the number of '#'s in the heading, and smaller number meaning higher level.

In markdown an internal URL has the form \[Link text\](#anchorId), where 'Link text' is displayed and `anchorId` is a code based on the text of the heading to which it links. The function uses the heading text as the link text, preceded by an up-arrow icon for a parent link and a down-arrow icon for a child link.

The `anchorId` is constructed by taking the heading text and transforming as follows:

- make text lower case
- replace space character, ' ', with hyphen, '-'
- remove all characters not in ([a-z], '-', '_')
- for duplicated headings, add a suffix '-1' for the first duplicated instance, then '-2' etc.

!#### Delinking

To exclude a heading from the tree of links, a '!' is added at the start of the heading line. This will be removed by the function so that it formats as a heading, and the subheading for this paragraph is an example of this.

The parameters are:

* `$headingsInpFile`: Name of the input file, which contains a list of the markdown constituent files

* `$mergedOutFile`: Name of the output file

Return value:

* `[string]`: List of headings
