class String
  def latex_escape
    replacements = {
      '\\' => '\textbackslash{}',
      '%'  => '\%',
      '$'  => '\$',
      '#'  => '\#',
      '&'  => '\&',
      '_'  => '\_',
      '{'  => '\{',
      '}'  => '\}',
      '~'  => '\textasciitilde{}',
      '^'  => '\textasciicircum{}',
      '<'  => '\textless{}',
      '>'  => '\textgreater{}'
    }
  
    escaped_string = to_s.gsub(/[&$#%_{}~^\\<>]/) { |char| replacements[char] }
    escaped_string
  end

  def latex_bold
    if Settings.function.show_highlight
      to_s.gsub(/\*\*(.*?)\*\*/) { |match| "\\textbf{#{$1}}" }
    else
      to_s.gsub(/\*\*(.*?)\*\*/, '\1')
    end
  end
end 