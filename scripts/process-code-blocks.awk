BEGIN {
  inCode = 0;
  code = "";  # The raw gab code to highlight
  highlightCmd = "$PWD" "/scripts/highlight";
}

inCode == 0 && $0 !~ /^<!--gab/ {
  # Print HTML other than <pre></pre> lines as-is
  print $0 >> outfile;
}

$0 == "</code></pre>" {
  # End of a code block
  if (inCode == 1) {
    printf "%s", "<pre><code>" >> outfile;
    print code | (highlightCmd " >> " outfile);
    close(highlightCmd " >> " outfile);
    printf "%s", "</code></pre>" >> outfile;

    inCode = 0;
    code = "";
  }
}

inCode == 1 {
  # Within code block
  code = code $0 "\n";
}

/^<!--gab/ {
  # Start of code block
  inCode = 1;
}
