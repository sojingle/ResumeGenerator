module LatexHelpers
  def link_to(text, href)
    href ? "\\href{#{href}}{\\underline{#{text}}}" : text
  end
end 