on run {input, parameters}
	-- input is a list of Finder items
	repeat with f in input
		set posixPath to POSIX path of f
		tell application "Terminal"
			activate
			-- use quoted form of path to safely escape spaces/special chars
			do script "docling " & quoted form of posixPath & " --output ~/Downloads; exec bash"
		end tell
	end repeat
	return input
end run
