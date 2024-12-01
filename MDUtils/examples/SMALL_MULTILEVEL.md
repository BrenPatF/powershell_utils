A small introduction for a single file example with multiple levels, including two top level headings, a duplicated heading, and a heading marked as not to be included in the link tree.

# Contents
[&darr; Level 2](#level-2)<br />

## Level 2
[&uarr; Contents](#contents)<br />
[&darr; Level 3](#level-3)<br />

Level 2 text.

### Level 3
[&uarr; Level 2](#level-2)<br />
[&darr; Level 4 - 1](#level-4---1)<br />
[&darr; Level 4 - 2](#level-4---2)<br />

Level 3 text.

#### Level 4 - 1
[&uarr; Level 3](#level-3)<br />

First level 4 text.

#### Level 4 - 2
[&uarr; Level 3](#level-3)<br />
[&darr; Level 5](#level-5)<br />

Second level 4 text.

##### Level 5 with leading !

Level 5 text. Headings with a leading ! in heading are not processed for internal links, but should still function as headings.

##### Level 5
[&uarr; Level 4 - 2](#level-4---2)<br />
[&darr; Level 6](#level-6)<br />

Level 5 text.

###### Level 6
[&uarr; Level 5](#level-5)<br />

Level 6 text. Level 6 headings are valid but don't have children as level 7 is not considered a heading.

####### 7-hash line prefix

Lines with 7 or more hashes as prefix are treated as plain text in markdown.

# Second Level 1 Heading
[&darr; Level 2](#level-2-1)<br />

## Level 2
[&uarr; Second Level 1 Heading](#second-level-1-heading)<br />

This is a duplicate heading, and the url has a '-1' suffix
