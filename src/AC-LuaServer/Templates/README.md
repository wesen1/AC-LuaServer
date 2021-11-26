Templates
=========

TextTemplates are used to generate single row strings. Leading and trailing whitespace per line, empty lines and line endings are removed. <br />
TableTemplates are the same like TextTemplates but use special tags to split the generated string into tables.

Both template types must have the file extension ".template".


Templating
----------

The template engine that is used to render the templates is lua-resty-template. <br/>
Refer to the [lua-resty-template](https://github.com/bungle/lua-resty-template) documentation for templating instructions.


### TextTemplate tags ###

### Config ###

The AC-ClientOutput library is used to ge

Use "##" + "[CONFIG]" or "[ENDCONFIG]"
TODO


#### Whitespace ####

If you want to add explicit whitespace at the start or the end of a line you can use the whitespace tag.

Use `<whitespace>` to create a single whitespace. <br/>
Use `<whitespace:x>` to create a specific number of whitespaces in a row


### TableTemplate Tags ###

TableTemplates can use the same tags like TextTemplates. <br/>
Additionally they can be split into rows and columns by using these tags:


#### Row separator ####

* At least 2x "_" followed by ";"
* The text will be split into rows at a row separator
* Example: `_____________;`

#### Column separator ####

* At least 2x "-" followed by ";"
* The text inside a row will be split into columns at a column separator
* Example: `-------------;`

#### Field Tag ####

* At least 2x "-" followed by "[FIELD]" or "[ENDFIELD]" and ending with zero or more "-" and ";"
* This will force the contents between the opening and closing field tag into a single row field in the current row
* Example: `------[FIELD]------;`, `------[ENDFIELD]------;`

Note: Each row inside a field tag must have the same number of columns


### Template Including ###

You can include other templates by using the `getAbsoluteTemplatePath` function and passing it the paths relative from the AssaultCube base folder to the templates.
