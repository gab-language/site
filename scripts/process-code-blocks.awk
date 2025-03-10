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
    printf "%s", "<div class=\"highlight\"><pre tabindex=\"0\" style=\"color:#f8f8f2;background-color:#272822;padding-left:2rem;\">" >> outfile;
    print code | (highlightCmd " >> " outfile);
    close(highlightCmd " >> " outfile);
    printf "%s", "</pre></div>" >> outfile;

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
