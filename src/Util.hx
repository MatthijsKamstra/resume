package;

import haxe.io.Path;

class Util {
	public static function exportPath():String {
		return Path.normalize(Sys.programPath().split('bin/')[0] + '/export/${currentTarget().toLowerCase()}');
	}

	public static function wwwPath():String {
		return Path.normalize(Sys.programPath().split('bin/')[0] + '/www/${currentTarget().toLowerCase()}');
	}

	public static function assetsPath():String {
		return Path.normalize(Sys.programPath().split('bin/')[0] + '/assets/');
	}

	public static function docsPath():String {
		return Path.normalize(Sys.programPath().split('bin/')[0] + '/docs');
	}

	public static function currentTarget():String {
		var ext = Path.extension(Sys.programPath());
		var target = '';
		switch (ext) {
			case 'py':
				target = 'Python';
			case 'cs':
				target = 'c#';
			case 'cpp':
				target = 'c++';
			case 'n':
				target = 'Neko';
			case 'lua':
				target = 'Lua';
			case 'java':
				target = 'Java';
			case 'js':
				// might need to read the lib used here?
				target = 'Node.js';
			default:
				trace("case '" + ext + "': trace ('" + ext + "');");
		}

		// check `/Users/matthijs/Documents/GIT/resume/bin/python/main.py`
		// trace('>>>' + Sys.getCwd());
		// trace('>>>' + Sys.programPath());
		// check for folder`/python` or use extension `.py`
		// Sys.programPath().split('bin/')[1].split('/')[0]; // yep, that works in this folder structure
		return target;
	}
}
