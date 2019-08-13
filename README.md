# EupheNix

This is a static site generator that uses [Nix](https://nixos.org/nix),
[Ruby](https://www.ruby-lang.org/en/), and [infuse](https://github.com/jucardi/infuse).

My goal was to ensure reproducible site builds, and ease of use. The prior is
provided by Nix, and the latter is of course subjective.

## Installation

You will need to have [Nix](https://nixos.org/nix) installed on your system to
be able to use EupheNix anyway, so once you have that you can easily go to the
next step.

To build the executable, you can run:

```shell-session
nix build -f https://github.com/manveru/euphenix/archive/master.tar.gz \
  euphenix --out-link euphenix
```

It will then be located in `./euphenix/bin/euphenix`. If you want to add it to your user profile, use:

```shell-session
nix-env -if ./euphenix
```

For declarative installation, use this instead:

```nix
let
  euphenixSource = import (fetchTarball {
    url = https://github.com/manveru/euphenix/archive/master.tar.gz;
  }) { };
in euphenixSource.euphenix
```

And then, depending on your system add `euphenixSource.eupehnix` to your
`environment.systemPackages` (on NixOS) or `home.packages` (in case of
home-manager)

Installation on other systems is left as an exercise for the reader.

## Usage

EupheNix is still a very young project, and only supports the use-cases I've
needed it for. While extending it is very easy, it heavily depends on _how_
you'd want to extend it. So for now I'll only cover what it does out of the box.

### Hello World

First we'll create a directory with our project, and within it, a file called
`default.nix`. The name indicates that when you run `nix-build` without
arguments, it will be built. If you want to name it otherwise, you may also do
so, but you will have to provide the name to `nix-build`, like
`nix-build example.nix`.

The contents of the file shall be this:

```nix
let
  euphenix = import (fetchTarball {
    url = https://github.com/manveru/euphenix/archive/master.tar.gz;
  }) { };
in euphenix.build {
  rootDir = ./.;
  layout = ./templates/layout.tmpl;
}
```

If you try to build this right away, you'll encounter an error message. That is
because we don't have any content to build yet.

Let's create a very simple layout at `templates/layout.tmpl` first:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>{{ .title | default "Title missing" }}</title>
  </head>
  <body>
    <main role="main">
      {{ yield }}
    </main>
  </body>
</html>
```

This is still not enough to actually render your site, since we also need some
content for the body.

So we'll make a file called `templates/index.tmpl` next:

```html
<!--
  title: Home
  route: /index.html
-->
<h1>Hello World!</h1>
```

This should suffice for now.

We can now build the site using `nix-build` and see the `result` directory
containing an `index.html` file.

You can either directly view this with your browser, or use the
`euphenix server` command to start a simple webserver.

I know this probably didn't immediately blow you away, but that was basically my
goal. You should be able to understand the whole process.

### Reload on change

While EupheNix doesn't come with live reloads built-in yet, the webserver
actually is already configured to work with [Live.js](http://livejs.com/).

Live.js may be from 2012, but it's still a really simple tool that is easy to
understand, use, and modify if needed. The added benefit is that it doesn't care
how your site is built.

For this tutorial we'll learn learn how to add some simple Javascript file to
your site.

Head over to their site, download the live.js file, and put it at
`static/js/live.js` in your project.

Modify the layout to look like this:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>{{ .title | default "Title missing" }}</title>
  </head>
  <body>
    <main role="main">
      {{ yield }}
    </main>

    <script src="/js/live.js"></script>
  </body>
</html>
```

Well done, refresh the site one last time manually, and every change you make
afterwards will automatically show up in your browser.

### Adding static files

So as you've seen, anytime we want to have a file copied without changes to the
`result` folder, we just put it into the `static` directory and EupheNix will
take care of it.

### Templating

We've already used some features of the default templating language used by
EupheNix. It's using [Infuse](https://github.com/jucardi/infuse) under the hood.

It may not be obvious at first sight, but Infuse uses the
[Go templating library](https://golang.org/pkg/text/template/) with a few
additions and makes it easy to use from the command-line.

The only addition to it is the `{{ yield }}` statement that is just a little
hack around the fact that you cannot dynamically change the name of the template
to render using the `{{ template "some.tmpl" . }}` helper.

#### Variables

The more interesting behavior comes from our use of an HTML front-matter in the
first comment in the `index.tmpl` file.

All the keys defined there can not only be used to influence builds of the site,
but are also available for interpolation within your templates. We see that if
we take a look at this snippet:

```html
<title>{{ .title | default "Title missing" }}</title>
```

Here we use the `title` specified in the `index.tmpl` and interpolate it for use
in the layout. If no title is set, we instead use the default.

There is also another way to inject variables into the build function itself, so
let's see how that goes. Modify your build function in `default.nix` to add the
`variables` key:

```nix
euphenix.build {
  rootDir = ./.;
  layout = ./templates/layout.tmpl;
  variables = { inception = builtins.readFile ./templates/index.tmpl; };
}
```

And in your `index.tmpl`, add the following line:

```html
<pre><code>{{ html .inception }}</code></pre>
```

Now you should see the code of the page in itself, pretty neat trick!

Note that when the variable is not set, and you don't give a fallback value
using the `default` function in the template, `<no value>` is inserted instead.

This can lead to really messed up rendering and is something I'd like to change
in future, but haven't gotten to yet. Generally it's a good idea to give a
default for now.

Variables can be any type that can be expressed in JSON: numbers, lists,
strings, and objects.

### Making a Blog

For our next exercise, we'll write a little blog post, display a list of them,
and have a page to show each.

The first part is quite simple again, just make a file at `blog/hello_world.md`
and write thus:

```markdown
---
title: First post
date: 2019-08-11
---

Just a simple entry, hopefully the first of many!
```

Next we shall make sure the posts are available for pages that need them by
passing them to the build as a variable:

```nix
  variables = {
    blogPosts = euphenix.loadPosts "/blog/" ./blog;
  };
```

Then we'll add the following code to the `index.tmpl`:

```html
<ul>
  {{ range .blogPosts }}
    <li><a href="{{ .url }}">{{ .meta.title }}</a></li>
  {{ end }}
</ul>
```

And should already see a simple list with our first post.
To actually display the post, we still have to provide a template that can do
that, I'll just call it `templates/post.tmpl`:

```html
<!--
  routeMaps: blogPosts
-->

<article>
  <h2><a href="{{.url}}">{{.meta.title}}</a></h2>
  <date datetime="{{.meta.date}}>{{.meta.date}}</date>
  <div>{{.body}}</div>
</article>

<a href="/">Back</a>
```

The magic here comes from `routeMaps`, which is a shitty name for mapping a
route for each entry of the given variable name.
The route by default will consist of a slug generated from the title of the blog
post and the first argument passed to the `loadPosts` function.

That's all I have time to write about today. Join us next time again to learn
about CSS compilation!

## History

I started this as a proof of concept, and out of frustration with existing site
generators like Hugo or Hakyll.

It's still at an early stage, but I think it's good enough for public
consumption after the 4th rewrite.

## Similar Projects

### Styx

This is the closest in spirit, but heavily relies on evaluating Nix within Nix,
which leads to poor performance. I also didn't need half of the features that it
provides, since I usually write my sites in plain HTML and CSS and don't use
common themes.
