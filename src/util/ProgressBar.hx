package util;

class ProgressBar {
	public function new() {}

	/**
	 * |█████████████████████████████████████████████-----| 90.0%
	 *
	 * @param  current 		progress value
	 * @param  total   		total value
	 */
	public static function out(current:Int, total:Int) {
		var _fill = '█';
		#if python
		// python really really doens't like this fill character
		_fill = 'X';
		#end
		var _empty = '-';
		var _current = '';
		var _rest = '';
		for (i in 0...current) {
			_current += _fill;
		}
		for (i in 0...(total - current)) {
			_rest += _empty;
		}
		var progress = '|${_current}${_rest}| ${Std.int((current / total) * 100)}%';
		Sys.stdout().writeString('\r' + progress + ' ');
		Sys.stdout().flush();
		#if lua
		// really weird, but lua needs this to update the cli
		Sys.print('');
		#end
	}
}
