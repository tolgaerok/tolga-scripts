5. Cheat Sheet
This cheat sheet provides a quick overview of all the Markdown syntax elements.
It can’t cover every edge case! If you need more information about any of these
elements, refer back to the chapters on basic and extended syntax.
Basic Syntax
These are the elements outlined in John Gruber’s original design document. All
Markdown applications support these elements.
Element
Heading
Bold
Italic
Blockquote
Ordered List
Unordered List
Code
HorizontalLink
Image
Rule
Markdown Syntax
# H1
## H2
### H3
**bold text**
*italicized text*
> blockquote
1. First item
2. Second item
3. Third item
- First item
- Second item
- Third item
`code`
---
[title](https://www.example.com)
![alt text](image.jpg)
Cheat Sheet
 61
Extended Syntax
These elements extend the basic syntax by adding additional features. Not all
Markdown applications support these elements.
Element
Table
Fenced Code Block
Footnote
Markdown Syntax
| Syntax | Description |
| ------ | ----------- |
| Header | Title |
| Paragraph | Text |
```
{
"firstName": "John",
"lastName": "Smith",
"age": 25
}
```
Here's a sentence with a footnote. [^1]
Heading ID
Definition List
Strikethrough
Task List
[^1]: This is the footnote.
### My Great Heading {#custom-id}
term
: definition
∼∼The world is flat.∼∼
- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media