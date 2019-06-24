# Resume

If you search for ["resume"](https://www.google.com/search?q=resume%20site%3Agithub.com&oq=gitub&) on [Github](https://github.com/search?q=resume) you will see a lot of repos that covers this problem:  **How to create a resume / CV / Curriculum Vitae**.

I'm not different; I like to reinvent the wheel (because my wheel is rounder!)

But I will learn from others: in my case from https://jsonresume.org/.

This project is `resume.json` but done with [Haxe](http://www.haxe.org) (readmore [here](README_HAXE.MD)). Because Haxe transpiles to a couple of System targets I am not limited to a specific language.

Language that I cover (with Haxe):

- node.js (without installing npm packages)
- python
- neko (something weird going on)
- lua (currently doesn't work)
- cpp (C++)
- cs (C#)
- java



## Categories

Because I'm bluntly copying the data (and probably research) from `resume.json` project, I have these categories I work with:P

- Basics
- Work
- Volunteer
- Education
- Awards
- Publications
- Skills
- Languages
- Interests
- References

Check the [`resume.md`](docs/resume.md) for more details



## Export

- [x] markdown (resume.md)
- [x] text (resume.txt)
- [x] html (resume.html)

But install [pandoc](https://pandoc.org/) and you can convert it to almost any filetype

For example convert markdown to `.docs` or `.odt` (because we love LibreOffice)

```bash
pandoc resume.md -f markdown -t docx -s -o resume.docx
pandoc resume.md -f markdown -t odt -s -o resume.odt
pandoc resume.md -f markdown -t html -s -o resume.html
```

I am going to be "lazy" and asume you have Pandoc installed (I am on osx so brew will work), but otherwise go to [Pandoc install](https://pandoc.org/installing.html)

```bash
brew install pandoc
```

## templates

default theme of jsonresume

- [jsonresume-theme-flat](https://github.com/erming/jsonresume-theme-flat)

dropin markdown converted html css templates

- [sakura](https://github.com/oxalorg/sakura)
- [buttondown](https://github.com/ryangray/buttondown)
- [markdowncss](https://github.com/markdowncss)
	- [slendor](https://github.com/markdowncss/splendor)
	- [modest](https://github.com/markdowncss/modest)
	- [air](https://github.com/markdowncss/air)
- [killercup](https://gist.github.com/killercup/5917178)
- [dashed](https://gist.github.com/dashed/6714393)


pandoc html via markdown

- [something](https://sdsawtelle.github.io/blog/output/simple-markdown-resume-with-pandoc-and-wkhtmltopdf.html)


```bash
pandoc --standalone --self-contained --table-of-contents --toc-depth=6 -t html5 --css=<css.css> <markdown.md> -o <html.html>
```


## About resume.json

A couple years back I ran into this project <https://jsonresume.org/>

> JSON Resume
> The open source initiative to create a JSON-based standard for resumes. For developers, by developers.

It seemed a good idea but I had no use for it.


Recently a colleague of mine needed a resume and I remembered this.
Now the project seems dead and most of the website is not working.

I still think it's a great idea, so I wanted to experiment with it.

After working with it, I only can say that it's a good idea. But currently it doesn't work properly.


Currently it's written in node.js and JavaScript.

We can probably do that better with Haxe!
So let's start a Haxe system variant for it.


## Source

- <https://jsonresume.org/>
- <https://github.com/jsonresume>
- <http://www.w3schools.com/json/>


# Haxe project

This is a [Haxe](http://www.haxe.org) project, read more about it in the [README_HAXE.MD](README_HAXE.MD)!