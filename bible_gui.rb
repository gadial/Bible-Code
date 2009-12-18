require 'bible_gui_def'
require 'Qt'
require 'bible'

class TextDisplayer < Qt::TextEdit
  def load_text(text)
    @text = text
    setCurrentFont(Qt::Font.new("Courier", 12))
    setText(@text.to_s)
    color_char(22,Qt::Color.new(Qt::red))
    color_char(51,Qt::Color.new(Qt::red))
    
#     clear_colors
  end
  def color_char(num,color)
    cursor = textCursor
    cursor.setPosition(num)
    cursor.movePosition(Qt::TextCursor::Right, Qt::TextCursor::KeepAnchor,1)
    format = cursor.charFormat
    format.setBackground(Qt::Brush.new(Qt::red))
    cursor.setCharFormat(format)
  end
  
  def clear_colors
    selectAll
    setTextBackgroundColor(Qt::Color.new(Qt::white))
#     clearSelection
  end
end

app = Qt::Application.new(ARGV)
window = Qt::MainWindow.new
window_ui = Ui::MainWindow.new
window_ui.setupUi(window)
window.show

o = Organizer.from_file("sample.txt")
window_ui.text_window.load_text(o.text)

app.exec
