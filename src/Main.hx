package;

import haxe.io.Path;
import sys.io.Process;
import AST;

using StringTools;

class Main {
	/**
	 * 0.0.1 	initial release
	 */
	var VERSION:String = '0.0.1';

	var NAME:String = 'Resume-hx';

	// resume data
	var json:ResumeObjObj;
	// defaults
	var TARGET:String; // current target (neko, node.js, c++, c#, python, java)
	var ASSETS:String; // root folder of the website
	var EXPORT:String; // folder to generate files in (in this case `www` folder from github )
	var DOCS:String; // folder to generate files in (in this case `docs` folder from github )
	// wip
	var __txt:String = '';
	var __md:String = '';
	var __arr:Array<String> = [];
	// template settings
	var settings:Dynamic; // should make this a typedef
	var template = 'splendor'; // default theme
	var isPandoc:Bool = false;

	var progressCounter = 0;
	var progressTotal = 7; // what is this?

	public function new(?args:Array<String>) {
		TARGET = Sys.getCwd().split('bin/')[1].split('/')[0]; // yep, that works in this folder structure
		EXPORT = Path.normalize(Sys.getCwd().split('bin/')[0] + '/www/${TARGET}'); // normal situation this would we just the `www` or `docs` folder
		DOCS = Path.normalize(Sys.getCwd().split('bin/')[0] + '/docs'); // normal situation this would we just the `www` or `docs` folder
		ASSETS = Path.normalize(Sys.getCwd().split('bin/')[0] + '/assets/');

		trace('[${TARGET}] Working with resume.json');

		Sys.println('[${TARGET}] CLI "${NAME}" ');

		// create some general information/settings which can be used for template generation
		settings = {
			title: '[${TARGET}] minimal static site generator',
			footer: 'Copyright &copy; ${Date.now().getFullYear()} - [mck]'
		}

		var args:Array<String> = args;

		if (args.length == 0)
			args.push('-h');

		for (i in 0...args.length) {
			var temp = args[i];
			switch (temp) {
				case '-t', '-theme', 'theme':
					template = args[i + 1];
				case '-i', '-init', 'init':
					trace(haxe.Resource.getString("resumeJson"));
				case '-v', '-version':
					Sys.println('version: ' + VERSION);
				case '-cd', '-folder': // isFolderSet = true;
				case '-help', '-h':
					showHelp();
				case '-out', '-o':
					writeAll();
				default:
					trace("case '" + temp + "': trace ('" + temp + "');");
			}
		}

		var path = Path.normalize(ASSETS + '/resume.json');

		if (sys.FileSystem.exists(path)) {
			var str:String = sys.io.File.getContent(path);
			json = haxe.Json.parse(str);
			// trace("json.basics.name: " + json.basics.name);
			writeAll();
		} else {
			trace('ERROR: there is no spoon: $path');
		}
	}

	// ____________________________________ write tools ____________________________________

	function writeAll() {
		isPandoc = isPandocInstalled();

		writeOut();
		writeTxt(); // first txt, because markdown modifice __txt (need to fix that)
		writeMarkdown();
		writeHtml();
		writeTemplate();
		writeTheme();
		// hack
		// template = 'index';
		// writeTheme();

		//
		flatTemp();

		index();
	}

	function index() {
		var arr = sys.FileSystem.readDirectory(DOCS);
		var html = '<ul>\n';
		for (i in 0...arr.length) {
			var _arr = arr[i];
			html += '\t<li><a href="${_arr}">${_arr}</a></li>\n';
		}
		html += '</ul>\n';

		var temp = '<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

    <title>Resume</title>
  </head>
  <body>
    <div class="container">
${html}

	</div>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
  </body>
</html>';

		writeFile(DOCS, 'index.html', temp);
	}

	function flatTemp() {
		var str = haxe.Resource.getString("htmlFlatTemplate");

		var template = new haxe.Template(str);

		var settings = {
			css: haxe.Resource.getString("flatTheme"),
			title: json.basics.name,
			basics: json.basics,
			profiles: json.basics.profiles,
			work: json.work,
			volunteer: json.volunteer,
			education: json.education,
			awards: json.awards,
			publications: json.publications,
			skills: json.skills,
			languages: json.languages,
			interests: json.interests,
			references: json.references,
		};

		var output = template.execute(settings);
		// return output;
		// trace(output);
		writeFile(EXPORT, 'resume-flat.html', output);
	}

	function writeTheme() {
		var css = haxe.Resource.getString("themeSplendor");
		switch (template) {
			case 'flat':
				flatTemp();
			case 'air':
				css = haxe.Resource.getString("themeAir");
			case 'modest':
				css = haxe.Resource.getString("themeModest");
			case 'splendor', 'index':
				css = haxe.Resource.getString("themeSplendor");
			case 'killercup':
				css = haxe.Resource.getString("themeKillercup");
			case 'dashed':
				css = haxe.Resource.getString("themeDashed");
			default:
				trace("case '" + template + "': trace ('" + template + "');");
		}
		writeFile(EXPORT, '${template}.css', css);

		if (isPandoc) {
			// trace(EXPORT);
			// trace(Path.normalize(EXPORT + '/../'));
			Sys.setCwd('${EXPORT}');
			// Sys.command('ls');
			// --toc for navigation
			// pandoc --standalone --self-contained --table-of-contents --toc-depth=6 -t html5 --css=<css.css> <markdown.md> -o <html.html>
			Sys.command('pandoc resume.md --standalone --self-contained --metadata pagetitle="${json.basics.name}" -c ${template}.css  -t html -o resume-${template}.html');

			// [mck] copy files to the docs folder... little weird if this was really a CLI
			Sys.command('mkdir -p ${Path.normalize(DOCS)}');
			Sys.command('cp * ${Path.normalize(DOCS)}');
		}
	}

	function isPandocInstalled():Bool {
		// Sys.println("Is Pandoc installed?");
		var p:Process = new Process('pandoc', ['-v']);
		var out = p.stdout.readAll().toString();
		p.close();

		if (out.indexOf('pandoc') != -1) {
			// trace('You have pandoc installed!');
			return true;
		} else {
			trace('Visit pandoc.org to install!');
			return false;
		}
		return false;
	}

	function writeOut() {
		// collect all the first level names of the nodes
		__arr = [];
		for (varName in Reflect.fields(json)) {
			__arr.push(capitalizeFirstLetter(varName));
		}
		// reset __txt and unwrap
		__txt = '';
		unwrapJson(json, '');
	}

	function writeMarkdown() {
		var str = '# ${json.basics.name}\n';
		str += '## ${json.basics.label}\n';
		str += '\n';

		// [mck] okay, this is little bit hacky, but it works
		// fix top level names
		for (i in 0...__arr.length) {
			var r = __arr[i];
			__txt = __txt.replace(r, '\n### ${r}::'); // convert to a h3 but add some extras so we can remove that in the next replace
		}
		// [mck] here some quick and dirty string manipulation
		__txt = __txt.replace(':::', '\n'); // created in the replace above and removed here
		__txt = __txt.replace('\t\t', '**- '); // convert the double tab
		__txt = __txt.replace('\t', '- **'); // convert tab to list
		__txt = __txt.replace('**- ', '\t- **'); // convert the double tab to dubble tab list
		__txt = __txt.replace(': ', ':** '); // create bold in combintaion with previous replace

		str += __txt;

		__md = Markdown.markdownToHtml(__txt);

		writeFile(EXPORT, 'resume.md', str);
	}

	function writeTxt():Void {
		var str = '${json.basics.name}\n';
		str += '${json.basics.label}\n';
		str += '\n';

		str += __txt;

		writeFile(EXPORT, 'resume.txt', str);
	}

	function writeHtml():Void {
		var str = '<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

    <title>${json.basics.name}</title>
  </head>
  <body>
    <main class="container">

		${__md}

	</main>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
  </body>
</html>';

		writeFile(EXPORT, 'resume.html', str);
	}

	function writeTemplate() {
		var str = haxe.Resource.getString("htmlTemplate");
		var template = new haxe.Template(str);

		var settings = {
			title: json.basics.name,
			work: json.work
		};

		var output = template.execute(settings);
		// return output;
		// trace(output);
		writeFile(EXPORT, 'resume-wip.html', output);
	}

	// ____________________________________ tools ____________________________________

	function unwrapJson(json:Dynamic, ?tab:String = '\t') {
		for (varName in Reflect.fields(json)) {
			// __txt += '${capitalizeFirstLetter(varName)}\n';
			// trace(varName, haxe.Json.stringify(Reflect.field(json, varName)));

			switch (Type.typeof(Reflect.field(json, varName))) {
				case TObject:
					__txt += '${tab}${capitalizeFirstLetter(varName)}: \n';
					// deeper into the rabit hole
					// trace('object : ${varName}');
					unwrapJson(Reflect.field(json, varName), tab + '\t');

				case TClass(String):
					// trace('${tab}string : ${varName} : ${Reflect.field(json, varName)}');
					__txt += '${tab}${capitalizeFirstLetter(varName)}: ${Reflect.field(json, varName)}\n';

				case TClass(Array):
					__txt += '${tab}${capitalizeFirstLetter(varName)}: \n';
					// trace('array : ${varName}');
					// trace('array : ${varName} : ${Reflect.field(json, varName)}');
					var arr:Array<Dynamic> = Reflect.field(json, varName);
					// trace('array: ${varName} :  ${arr.length}');
					for (i in 0...arr.length) {
						var _json = haxe.Json.parse(haxe.Json.stringify(arr[i]));
						unwrapJson(_json, tab + '\t');
						// trace('--------> ${i}, ${haxe.Json.stringify(_json)}');
					}

				default:
					// trace(">>>>>> " + Type.typeof(pjson));
					// trace(">>>>>> " + (Reflect.field(pjson,i)));
					#if neko
					__txt += '${tab}${capitalizeFirstLetter(varName)}: ${Reflect.field(json, varName)}\n';
					#else
					trace("[FIXME] type: " + Type.typeof(Reflect.field(json, varName)) + ' / ${varName}: ' + Reflect.field(json, varName));
					#end
			}
		}
	}

	/**
	 * does what it says
	 * @param string 	convert this to a word that starts with a capital (word -> Word)
	 * @return String
	 */
	function capitalizeFirstLetter(string:String):String {
		return string.charAt(0).toUpperCase() + string.substring(1);
	}

	/**
	 * simply write the files
	 * @param path 		folder to write the files (current assumption is `EXPORT`)
	 * @param filename	(with extension) the file name
	 * @param content	what to write to the file (in our case markdown)
	 */
	function writeFile(path:String, filename:String, content:String) {
		if (!sys.FileSystem.exists(path)) {
			sys.FileSystem.createDirectory(path);
		}
		// write the file
		sys.io.File.saveContent(path + '/${filename}', content);
		// trace('written file: ${path}/${filename}');
		progressCounter++;
		// util.ProgressBar.out(progressCounter, progressTotal);
		// trace('count: ${progressCounter}/${progressTotal}');
	}

	function correctCLI(target:String):String {
		var str = '';
		switch (target) {
			case 'neko':
				str = 'neko main';
			case 'cpp':
				str = '/Main';
			case 'cs':
				str = 'mono Main.exe';
			case 'java':
				str = 'java -jar Main.jar';
			case 'lua':
				str = 'lua main.lua';
			case 'node':
				str = 'node main.js';
			case 'python':
				str = 'python3 main.py';
			default:
				str = '[xxx]';
				trace("case '" + target + "': trace ('" + target + "');");
		}
		return str;
	}

	/**
	 *   -f FORMAT, -r FORMAT  --from=FORMAT, --read=FORMAT
	 */
	function showHelp():Void {
		var str = '';
		str += '------------------------------------------------\n';
		str += '${NAME} ($VERSION)\n';
		str += '\n';
		str += 'How to use (${TARGET}):\n';
		str += '${correctCLI(TARGET)} -out\n';
		str += '\n';
		str += '	-version / -v   : version number\n';
		str += '	-help / -h      : show this help\n';
		str += '	-folder / -cd   : path to project folder\n';
		str += '	-out / -o       : write readme\n';
		str += '\n';
		str += '------------------------------------------------\n';
		Sys.println(str);
	}

	// ____________________________________ starting point ____________________________________

	static public function main():Void {
		var app = new Main(Sys.args());
	}
}
