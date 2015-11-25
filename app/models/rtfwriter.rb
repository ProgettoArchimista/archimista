GCrwStyleNormal = 0
GCrwStyleHeading1 = 1
GCrwStyleHeading2 = 2
GCrwStyleHeading3 = 3
GCrwStyleHeading4 = 4
GCrwStyleHeading5 = 5
GCrwStyleHeading = 6
GCrwStylePredefinedCount = 7
GCrwStyleCurrent = -1

GCrwFontNameTimesNewRoman = 0
GCrwFontNameArial = 1
GCrwFontNameMSSansSerif = 2
GCrwFontNameCourierNew = 3
GCrwFontNameVerdana = 4
GCrwFontNameSymbol = 5
GCrwFontNameCurrent = -1

GCrwFontBoldDisabled = 0
GCrwFontBoldEnabled = 1
GCrwFontBoldCurrent = -1

GCrwFontItalicDisabled = 0
GCrwFontItalicEnabled = 1
GCrwFontItalicCurrent = -1

GCrwFontUnderlinedDisabled = 0
GCrwFontUnderlinedEnabled = 1
GCrwFontUnderlinedCurrent = -1

GCrwTextAlignmentLeft = 0
GCrwTextAlignmentCenter = 1
GCrwTextAlignmentRight = 2
GCrwTextAlignmentJustified = 3
GCrwTextAlignmentCurrent = -1

GCrwTextColorBlack = 0
GCrwTextColorMaroon = 1
GCrwTextColorGreen = 2
GCrwTextColorOlive = 3
GCrwTextColorNavy = 4
GCrwTextColorPurple = 5
GCrwTextColorTeal = 6
GCrwTextColorGray = 7
GCrwTextColorSilver = 8
GCrwTextColorRed = 9
GCrwTextColorLime = 10
GCrwTextColorYellow = 11
GCrwTextColorBlue = 12
GCrwTextColorFuchsia = 13
GCrwTextColorAqua = 14
GCrwTextColorWhite = 15
GCrwTextColorCurrent = -1

GCrwIndentationCMQuarters00 = 0
GCrwIndentationCMQuarters01 = 142
GCrwIndentationCMQuarters02 = 282
GCrwIndentationCMQuarters03 = 426
GCrwIndentationCMQuarters04 = 568
GCrwIndentationCMQuarters05 = 710
GCrwIndentationCMQuarters06 = 852
GCrwIndentationCMQuarters07 = 994
GCrwIndentationCMQuarters08 = 1136
GCrwIndentationCMQuarters09 = 1278
GCrwIndentationCMQuarters10 = 1420
GCrwIndentationCMQuartersCurrent = 10000

GCrwHeaderFooterPageBoth = 0
GCrwHeaderFooterPageLeft = 1
GCrwHeaderFooterPageRight = 2

class RtfWriter

  MCfileOpenModeRead = 0
  MCfileOpenModeWrite = 1
  MCfileOpenModeAppend = 2

  MCAlignmentChars = "lcrj"

  def initialize
    @file = nil
    @currentLineIndentationIndex = 0
    @currentFirstLineIndentationIndex = 0
  end

  def IsOpen?
    return !@file.nil?
  end

  def FileCreate(filename)
    @file = File.open(filename, "w:ISO-8859-1")
  #  @file = File.open(filename, "w")
  end

  def FileClose
    if (!self.IsOpen?) then return end

    @file.close
    @file = nil
  end

  def writeFileHead(custom_stylesheets = nil)
    status = false
    i = 0

    if (!self.IsOpen?) then return end

    status = prvAsciiFilePutLine(@file, "{\\rtf1\\ansi \\deff0")

    status = prvAsciiFilePutLine(@file, "{\\fonttbl")
    status = prvAsciiFilePutLine(@file, "\\f0\\froman Times New Roman;")
    status = prvAsciiFilePutLine(@file, "\\f1\\fswiss Arial;")
    status = prvAsciiFilePutLine(@file, "\\f2\\fswiss MS Sans Serif;")
    status = prvAsciiFilePutLine(@file, "\\f3\\fmodern Courier New;")
    status = prvAsciiFilePutLine(@file, "\\f4\\fswiss Verdana;")
    status = prvAsciiFilePutLine(@file, "\\f5\\fnil Symbol;")
    #eliminato additionalFontNames
    status = prvAsciiFilePutLine(@file, "}")

    status = prvAsciiFilePutLine(@file, "{\\colortbl;")
    status = prvAsciiFilePutLine(@file, "\\red127\\green0\\blue0;")
    status = prvAsciiFilePutLine(@file, "\\red0\\green127\\blue0;")
    status = prvAsciiFilePutLine(@file, "\\red127\\green127\\blue0;")
    status = prvAsciiFilePutLine(@file, "\\red0\\green0\\blue127;")
    status = prvAsciiFilePutLine(@file, "\\red127\\green0\\blue127;")
    status = prvAsciiFilePutLine(@file, "\\red0\\green127\\blue127;")
    status = prvAsciiFilePutLine(@file, "\\red127\\green127\\blue127;")
    status = prvAsciiFilePutLine(@file, "\\red192\\green192\\blue192;")
    status = prvAsciiFilePutLine(@file, "\\red255\\green0\\blue0;")
    status = prvAsciiFilePutLine(@file, "\\red0\\green255\\blue0;")
    status = prvAsciiFilePutLine(@file, "\\red255\\green255\\blue0;")
    status = prvAsciiFilePutLine(@file, "\\red0\\green0\\blue255;")
    status = prvAsciiFilePutLine(@file, "\\red255\\green0\\blue255;")
    status = prvAsciiFilePutLine(@file, "\\red0\\green255\\blue255;")
    status = prvAsciiFilePutLine(@file, "\\red255\\green255\\blue255;")
    #eliminato additionalColors
    status = prvAsciiFilePutLine(@file, "}")

    status = prvAsciiFilePutLine(@file, "{\\stylesheet")
    status = prvAsciiFilePutLine(@file, "{\\fs24 \\snext0Normal;}")
    status = prvAsciiFilePutLine(@file, "{\\s1\\ql\\b\\f0\\fs30 heading 1;}")
    status = prvAsciiFilePutLine(@file, "{\\s2\\ql\\b\\f0\\fs28 heading 2;}")
    status = prvAsciiFilePutLine(@file, "{\\s3\\ql\\b\\f0\\fs26 heading 3;}")
    status = prvAsciiFilePutLine(@file, "{\\s4\\ql\\b\\f0\\fs24 heading 4;}")
    status = prvAsciiFilePutLine(@file, "{\\s5\\ql\\b\\f0\\fs22 heading 5;}")
    status = prvAsciiFilePutLine(@file, "{\\s6\\ql\\b\\f0\\fs36 Titolo;}")
		if !custom_stylesheets.nil?
			custom_stylesheets.each do |stylesheet|
				status = prvAsciiFilePutLine(@file, stylesheet)
			end
		end
    status = prvAsciiFilePutLine(@file, "}")

    status = prvAsciiFilePutLine(@file, "\\fs20\\f1")
  end

  def writeFileTail()
    status = false

    if (!self.IsOpen?) then return end

    status = prvAsciiFilePutLine(@file, "}")
  end

  def writeText(parText, styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil, fntBoldIndex = nil, fntItalicIndex = nil, fntUnderlinedIndex = nil, txtAlignmentIndex = nil, txtColorIndex = nil, lineIndentationIndex = nil, firstLineIndentationIndex = nil)
    txtSettings = ""
    txtPrefix = ""
    txtPostfix = ""
    status = false

    if (!self.IsOpen?) then return end

    if styleIndex.nil? then styleIndex = GCrwStyleCurrent end
    if fntNameIndex.nil? then fntNameIndex = GCrwFontNameCurrent end
    if fntSizeValue.nil? then fntSizeValue = 0 end
    if fntBoldIndex.nil? then fntBoldIndex = GCrwFontBoldCurrent end
    if fntItalicIndex.nil? then fntItalicIndex = GCrwFontItalicCurrent end
    if fntUnderlinedIndex.nil? then fntUnderlinedIndex = GCrwFontUnderlinedCurrent end
    if txtAlignmentIndex.nil? then txtAlignmentIndex = GCrwTextAlignmentCurrent end
    if txtColorIndex.nil? then txtColorIndex = GCrwTextColorCurrent end
    if lineIndentationIndex.nil? then lineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if firstLineIndentationIndex.nil? then firstLineIndentationIndex = GCrwIndentationCMQuartersCurrent end

    txtSettings = prvCreateSettings(styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, lineIndentationIndex, firstLineIndentationIndex)
    if (txtSettings != "") then
      txtPrefix = "{" + txtSettings + " "
      txtPostfix = "}"
    end

    status = prvAsciiFilePutLine(@file, txtPrefix + parText.to_s.gsub("\\", "\\\\") + txtPostfix)
  end

  def writeParagraph(parText, styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil, fntBoldIndex = nil, fntItalicIndex = nil, fntUnderlinedIndex = nil, txtAlignmentIndex = nil, txtColorIndex = nil, lineIndentationIndex = nil, firstLineIndentationIndex = nil)
    txtSettings = ""
    txtPrefix = ""
    txtPostfix = ""
    parTextLines = []
    status = false

    if (!self.IsOpen?) then return end

    if styleIndex.nil? then styleIndex = GCrwStyleCurrent end
    if fntNameIndex.nil? then fntNameIndex = GCrwFontNameCurrent end
    if fntSizeValue.nil? then fntSizeValue = 0 end
    if fntBoldIndex.nil? then fntBoldIndex = GCrwFontBoldCurrent end
    if fntItalicIndex.nil? then fntItalicIndex = GCrwFontItalicCurrent end
    if fntUnderlinedIndex.nil? then fntUnderlinedIndex = GCrwFontUnderlinedCurrent end
    if txtAlignmentIndex.nil? then txtAlignmentIndex = GCrwTextAlignmentCurrent end
    if txtColorIndex.nil? then txtColorIndex = GCrwTextColorCurrent end
    if lineIndentationIndex.nil? then lineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if firstLineIndentationIndex.nil? then firstLineIndentationIndex = GCrwIndentationCMQuartersCurrent end

    txtSettings = prvCreateSettings(styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, lineIndentationIndex, firstLineIndentationIndex)

    if (txtSettings != "") then
      txtPrefix = "{" + txtSettings + " "
      txtPostfix = "}"
    end

    if (parText != "") then
      parTextLines = parText.to_s.gsub("\r\n", "\n").split("\n")

      n = parTextLines.length
      isStartTagUnordered = Array.new(n){ |i| false }
      isEndTagUnordered = Array.new(n){ |i| false }

      pc = unorderedListGetPointChar(nil)
      posFrom = -1
      posTo = -1
      parTextLines.each_with_index do |parTextLine, index|
        if parTextLine.length >= 2 && parTextLine[0..1] == "* "
          if posFrom == -1
            posFrom = index
          end
        else
          if posFrom >= 0
            posTo = index - 1
          end
        end
        if posFrom >= 0 and posTo == -1 and index == parTextLines.length - 1
          posTo = index
        end
        if posFrom >= 0 and posTo >= 0
          s = parTextLines[posFrom]
          if s.length >= 2
            s = s[2..s.length - 1]
          end
          parTextLines[posFrom] = unorderedListGetItem(s, pc)
          isStartTagUnordered[posFrom] = true

          if posFrom + 1 <= posTo - 1
            i = posFrom + 1
            for posIndex in [posFrom + 1..posTo - 1]
              s = parTextLines[i]
              if s.length >= 2
                s = s[2..s.length - 1]
              end
              parTextLines[i] = unorderedListGetItem(s, pc)
              i += 1
            end
          end

          if posTo > posFrom
            s = parTextLines[posTo]
            if s.length >= 2
              s = s[2..s.length - 1]
            end
            parTextLines[posTo] = unorderedListGetItem(s, pc)
          end
          isEndTagUnordered[posTo] = true

          posFrom = -1
          posTo = -1
        end
      end

      isStartTagOrdered = Array.new(n){ |i| false }
      isEndTagOrdered = Array.new(n){ |i| false }
      posFrom = -1
      posTo = -1
      parTextLines.each_with_index do |parTextLine, index|
        if parTextLine.length >= 2 && parTextLine[0..1] == "# "
          if posFrom == -1
            posFrom = index
          end
        else
          if posFrom >= 0
            posTo = index - 1
          end
        end
        if posFrom >= 0 and posTo == -1 and index == parTextLines.length - 1
          posTo = index
        end
        if posFrom >= 0 and posTo >= 0
          j = 1

          s = parTextLines[posFrom]
          if s.length >= 2
            s = s[2..s.length - 1]
          end
          parTextLines[posFrom] = orderedListGetItem(s, j)
          isStartTagOrdered[posFrom] = true
          j += 1

          if posFrom + 1 <= posTo - 1
            i = posFrom + 1
            for posIndex in [posFrom + 1..posTo - 1]
              s = parTextLines[i]
              if s.length >= 2
                s = s[2..s.length - 1]
              end
              parTextLines[i] = orderedListGetItem(s, j)
              i += 1
              j += 1
            end
          end

          if posTo > posFrom
            s = parTextLines[posTo]
            if s.length >= 2
              s = s[2..s.length - 1]
            end
            parTextLines[posTo] = orderedListGetItem(s, j)
          end
          isEndTagOrdered[posTo] = true

          posFrom = -1
          posTo = -1
        end
      end

      parTextLines.each_with_index do |parTextLine, index|
        parTextLine = parTextLine.to_s.gsub("\\", "\\\\")
        if parTextLine.length >= 2
          if parTextLine[0] == "_" or parTextLine.include?(" _")
            parTextLine = " " + parTextLine + " "
            while parTextLine.include?(" _") && parTextLine.include?("_ ")
              parTextLine.sub!(" _", " \\i1 ")
              parTextLine.sub!("_ ", "\\i0  ")
            end
            parTextLine = parTextLine[1..parTextLine.length - 2]
          end

          if parTextLine[0] == "*" or parTextLine.include?(" *")
            parTextLine = " " + parTextLine + " "
            while parTextLine.include?(" *") && parTextLine.include?("* ")
              parTextLine.sub!(" *", " \\b1 ")
              parTextLine.sub!("* ", "\\b0  ")
            end
            parTextLine = parTextLine[1..parTextLine.length - 2]
          end
        end
        if isStartTagUnordered[index]
          status = prvAsciiFilePutLine(@file, unorderedListGetStartTag(pc))
        end
        if isStartTagOrdered[index]
          status = prvAsciiFilePutLine(@file, orderedListGetStartTag(1))
        end
        status = prvAsciiFilePutLine(@file, txtPrefix + parTextLine + "\\par" + txtPostfix)
        if isEndTagUnordered[index]
          status = prvAsciiFilePutLine(@file, unorderedListGetEndTag())
        end
        if isEndTagOrdered[index]
          status = prvAsciiFilePutLine(@file, orderedListGetEndTag())
        end
      end
    elsif
      status = prvAsciiFilePutLine(@file, txtPrefix + "\\par" + txtPostfix)
    end
  end
  
  def writeLineSeparator(styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil)
    if styleIndex.nil? then
      style = ""
    else
      style = "\\s" + styleIndex.to_s
    end

    if fntNameIndex.nil? then
      fntName = ""
    else
      fntName = "\\f" + styleIndex.to_s
    end

    if fntSizeValue.nil? then
      fntSize = "\\fs16"
    else
      fntSize = "\\fs" + fntSizeValue.to_s
    end

    ls = "{\\pard \\brdrb \\brdrs\\brdrw10\\brsp20#{style} {#{fntName}#{fntSize}\\~}\\par \\pard}{\\pard #{style}#{fntName}#{fntSize}\\par \\pard}"

    status = prvAsciiFilePutLine(@file, ls)
  end

  def unorderedListGetPointChar(pointChar = nil)
    if pointChar.nil?
      return "\\'B7"
    else
      return "\f0 " + pointChar
    end
  end

  def unorderedListGetStartTag(rtfPointChar)
    return "\\pard\n" + "{\\*\\pn\\pnlvlblt\\pnf5\\pnindent0{\\pntxtb" + rtfPointChar + "}}\\fi-284\\li284"
  end

  def unorderedListWriteStartTag(rtfPointChar)
    status = prvAsciiFilePutLine(@file, unorderedListGetStartTag(rtfPointChar))
  end

  def unorderedListGetItem(itemText, rtfPointChar)
    return "{\\pntext" + rtfPointChar + "\\tab}" + itemText
  end

  def unorderedListWriteItem(itemText, rtfPointChar)
    status = prvAsciiFilePutLine(@file, unorderedListGetItem(itemText, rtfPointChar))
  end

  def unorderedListGetEndTag()
    return "\\\pard"
  end

  def unorderedListWriteEndTag()
    status = prvAsciiFilePutLine(@file, unorderedListGetEndTag())
  end


  def orderedListGetStartTag(startIndex)
    return "\\pard\n" + "{\\*\\pn\\pnlvlbody\\pnf0\\pnindent0\\pnstart" + startIndex.to_s + "\\pndec{\\pntxta.}}\\fi-284\\li284"
  end

  def orderedListWriteStartTag(startIndex = 1)
    status = prvAsciiFilePutLine(@file, orderedListGetStartTag(startIndex))
  end
  
  def orderedListGetItem(itemText, itemIndex)
    return "{\\pntext\\f0 " + itemIndex.to_s + ".\\tab}" + itemText
  end
  
  def orderedListWriteItem(itemText, itemIndex)
    status = prvAsciiFilePutLine(@file, orderedListGetItem(itemText, itemIndex))
  end

  def orderedListGetEndTag()
    return "\\pard"
  end

  def orderedListWriteEndTag()
    status = prvAsciiFilePutLine(@file, orderedListGetEndTag())
  end

  def writeSettings(styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil, fntBoldIndex = nil, fntItalicIndex = nil, fntUnderlinedIndex = nil, txtAlignmentIndex = nil, txtColorIndex = nil, lineIndentationIndex = nil, firstLineIndentationIndex = nil)
    txtSettings = ""
    status = false

    if (!self.IsOpen?) then return end

    if styleIndex.nil? then styleIndex = GCrwStyleCurrent end
    if fntNameIndex.nil? then fntNameIndex = GCrwFontNameCurrent end
    if fntSizeValue.nil? then fntSizeValue = 0 end
    if fntBoldIndex.nil? then fntBoldIndex = GCrwFontBoldCurrent end
    if fntItalicIndex.nil? then fntItalicIndex = GCrwFontItalicCurrent end
    if fntUnderlinedIndex.nil? then fntUnderlinedIndex = GCrwFontUnderlinedCurrent end
    if txtAlignmentIndex.nil? then txtAlignmentIndex = GCrwTextAlignmentCurrent end
    if txtColorIndex.nil? then txtColorIndex = GCrwTextColorCurrent end
    if lineIndentationIndex.nil? then lineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if firstLineIndentationIndex.nil? then firstLineIndentationIndex = GCrwIndentationCMQuartersCurrent end

    txtSettings = prvCreateSettings(styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, lineIndentationIndex, firstLineIndentationIndex)

    status = prvAsciiFilePutLine(@file, txtSettings)

    prvSetIndentation(lineIndentationIndex, firstLineIndentationIndex)
  end

  def writeDefaultSettings()
    writeDefaultSettings = writeSettings(GCrwStyleNormal, GCrwFontNameTimesNewRoman, 12, GCrwFontBoldDisabled, GCrwFontItalicDisabled, GCrwFontUnderlinedDisabled, GCrwTextAlignmentLeft, GCrwTextColorBlack)
  end

  def writeStyle(styleIndex)
    status = false

    if (!self.IsOpen?) then return end

    if (styleIndex == GCrwStyleCurrent) then
      status = true
    else
      status = prvAsciiFilePutLine(@file, "\\s" + styleIndex.to_s)
    end 
  end

  def writeIndentation(lineIndentationIndex, firstLineIndentationIndex)
    txtIndentation = ""
    status = false

    if (!self.IsOpen?) then return end

    txtIndentation = ""
    if (lineIndentationIndex != GCrwIndentationCMQuartersCurrent) then
      txtIndentation = "\\li" + lineIndentationIndex.to_s
    end

    if (firstLineIndentationIndex != GCrwIndentationCMQuartersCurrent) then
      txtIndentation = txtIndentation + "\\fi" + firstLineIndentationIndex.to_s
    end

    if (txtIndentation != "") then
      status = prvAsciiFilePutLine(@file, txtIndentation)
    end

    prvSetIndentation(lineIndentationIndex, firstLineIndentationIndex)

    status = true
  end

  def writeNewPage()
    status = false

    if (!self.IsOpen?) then return end

    status = prvAsciiFilePutLine(@file, "\\page")
  end

  def writeNewLine(styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil, fntBoldIndex = nil, fntItalicIndex = nil, fntUnderlinedIndex = nil, txtAlignmentIndex = nil, txtColorIndex = nil, lineIndentationIndex = nil, firstLineIndentationIndex = nil)
    status = false

    if (!self.IsOpen?) then return end

    writeParagraph("", styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, lineIndentationIndex, firstLineIndentationIndex)
  end

  def writeHeader(hdrText, styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil, fntBoldIndex = nil, fntItalicIndex = nil, fntUnderlinedIndex = nil, txtAlignmentIndex = nil, txtColorIndex = nil, lineIndentationIndex = nil, firstLineIndentationIndex = nil, pageTarget = nil)
    txtPrefix = ""
    txtPostfix = ""
    txtSettings = ""
    status = false

    if (!self.IsOpen?) then return end

    if styleIndex.nil? then styleIndex = GCrwStyleCurrent end
    if fntNameIndex.nil? then fntNameIndex = GCrwFontNameCurrent end
    if fntSizeValue.nil? then fntSizeValue = 0 end
    if fntBoldIndex.nil? then fntBoldIndex = GCrwFontBoldCurrent end
    if fntItalicIndex.nil? then fntItalicIndex = GCrwFontItalicCurrent end
    if fntUnderlinedIndex.nil? then fntUnderlinedIndex = GCrwFontUnderlinedCurrent end
    if txtAlignmentIndex.nil? then txtAlignmentIndex = GCrwTextAlignmentCurrent end
    if txtColorIndex.nil? then txtColorIndex = GCrwTextColorCurrent end
    if lineIndentationIndex.nil? then lineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if firstLineIndentationIndex.nil? then firstLineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if pageTarget.nil? then pageTarget = GCrwHeaderFooterPageBoth end

    txtSettings = prvCreateSettings(styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, lineIndentationIndex, firstLineIndentationIndex)
    if (txtSettings != "") then
      txtPrefix = txtSettings + " {"
      txtPostfix = "}"
    end

    case pageTarget
      when GCrwHeaderFooterPageLeft
        pt = "l"
      when GCrwHeaderFooterPageRight
        pt = "r"
      else
        pt = ""
    end
    status = prvAsciiFilePutLine(@file, "{\\header" + pt + " " + txtPrefix + hdrText + txtPostfix + "{\\par}}")
  end

  def writeFooter(ftrText, styleIndex = nil, fntNameIndex = nil, fntSizeValue = nil, fntBoldIndex = nil, fntItalicIndex = nil, fntUnderlinedIndex = nil, txtAlignmentIndex = nil, txtColorIndex = nil, lineIndentationIndex = nil, firstLineIndentationIndex = nil, pageTarget = nil)
    tmpFtrText = ""
    txtPrefix = ""
    txtPostfix = ""
    txtSettings = ""
    status = false

    if (!self.IsOpen?) then return end

    if styleIndex.nil? then styleIndex = GCrwStyleCurrent end
    if fntNameIndex.nil? then fntNameIndex = GCrwFontNameCurrent end
    if fntSizeValue.nil? then fntSizeValue = 0 end
    if fntBoldIndex.nil? then fntBoldIndex = GCrwFontBoldCurrent end
    if fntItalicIndex.nil? then fntItalicIndex = GCrwFontItalicCurrent end
    if fntUnderlinedIndex.nil? then fntUnderlinedIndex = GCrwFontUnderlinedCurrent end
    if txtAlignmentIndex.nil? then txtAlignmentIndex = GCrwTextAlignmentCurrent end
    if txtColorIndex.nil? then txtColorIndex = GCrwTextColorCurrent end
    if lineIndentationIndex.nil? then lineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if firstLineIndentationIndex.nil? then firstLineIndentationIndex = GCrwIndentationCMQuartersCurrent end
    if pageTarget.nil? then pageTarget = GCrwHeaderFooterPageBoth end

    txtSettings = prvCreateSettings(styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, lineIndentationIndex, firstLineIndentationIndex)
    if (txtSettings != "") then
      txtPrefix = txtSettings + " {"
      txtPostfix = "}"
    end

    tmpFtrText = ftrText
    tmpFtrText = tmpFtrText.gsub("%PAGE%", "{\\field{\\*\\fldinst { PAGE }}}")
    tmpFtrText = tmpFtrText.gsub("%NUMPAGES%", "{\\field{\\*\\fldinst { NUMPAGES }}}")

    case pageTarget
      when GCrwHeaderFooterPageLeft
        pt = "l"
      when GCrwHeaderFooterPageRight
        pt = "r"
      else
        pt = ""
    end

    status = prvAsciiFilePutLine(@file, "{\\footer" + pt + " " + txtPrefix + tmpFtrText + txtPostfix + "{\\par}}")
  end

  def writeRaw(txt)
    status = prvAsciiFilePutLine(@file, txt)
  end

  private

  def prvAsciiFilePutLine(fileObj, txtLine)
    begin
      fileObj.write txtLine + "\n"
    rescue
      begin
        wrkTxtLine = prvAnsiiToRtfRemap(txtLine)
        fileObj.write wrkTxtLine + "\n"
      rescue
      end
    end
  end

  def prvCreateSettings(styleIndex, fntNameIndex, fntSizeValue, fntBoldIndex, fntItalicIndex, fntUnderlinedIndex, txtAlignmentIndex, txtColorIndex, indentationIndex, firstLineIndentationIndex)
    txtSettings = ""

    if (styleIndex != GCrwStyleCurrent) then
      txtSettings = txtSettings + "\\s" + styleIndex.to_s
    end
    if (fntNameIndex != GCrwFontNameCurrent) then
      if (fntNameIndex >= 0) then
        txtSettings = txtSettings + "\\f" + fntNameIndex.to_s
      else
        fntNameIndex = rwFontNameCurrent - 1 + (fntNameIndex * -1)
        txtSettings = txtSettings + "\\f" + fntNameIndex.to_s
      end
    end
    if (fntSizeValue != 0) then
      txtSettings = txtSettings + "\\fs" + (fntSizeValue * 2).to_s
    end
    if (fntBoldIndex != GCrwFontBoldCurrent) then
      txtSettings = txtSettings + "\\b" + fntBoldIndex.to_s
    end
    if (fntItalicIndex != GCrwFontItalicCurrent) then
      txtSettings = txtSettings + "\\i" + fntItalicIndex.to_s
    end
    if (fntUnderlinedIndex != GCrwFontUnderlinedCurrent) then
      txtSettings = txtSettings + "\\ul" + fntUnderlinedIndex.to_s
    end
    if (txtAlignmentIndex != GCrwTextAlignmentCurrent) then
      txtSettings = txtSettings + "\\q" + MCAlignmentChars[txtAlignmentIndex, 1]
    end
    if (txtColorIndex != GCrwTextColorCurrent) then
      if (txtColorIndex >= 0) then
        txtSettings = txtSettings + "\\cf" + txtColorIndex.to_s
      else
        txtColorIndex = rwTextColorCurrent - 1 + (txtColorIndex * -1)
        txtSettings = txtSettings + "\\cf" + txtColorIndex.to_s
      end
    end
    if (indentationIndex != GCrwIndentationCMQuartersCurrent) then
      txtSettings = txtSettings + "\\li" + indentationIndex.to_s
    end
    if (firstLineIndentationIndex != GCrwIndentationCMQuartersCurrent) then
      txtSettings = txtSettings + "\\fi" + firstLineIndentationIndex.to_s
    end

    return txtSettings
  end

  def prvSetIndentation(lineIndentationIndex, firstLineIndentationIndex)
    if (lineIndentationIndex != GCrwIndentationCMQuartersCurrent)
      @currentLineIndentationIndex = lineIndentationIndex
    end
    if (firstLineIndentationIndex != GCrwIndentationCMQuartersCurrent)
      @currentFirstLineIndentationIndex = firstLineIndentationIndex
    end
  end

  def prvAnsiiToRtfRemap(ipStr)
    opStr = ""

    i = 0
    ipStr.each_char do |c|
      if c.ord < 128
        opStr = opStr + ipStr[i]
      elsif c.ord < 256
        opStr = opStr + "\\\'" + c.ord.to_s(16)
      else
        case c.ord
          when 8364
            opStr = opStr + "\\\'80"
          when 402
            opStr = opStr + "\\\'83"
          when 8230
            opStr = opStr + "\\\'85"
          when 710
            opStr = opStr + "\\\'88"
          when 8240
            opStr = opStr + "\\\'89"
          when 8249
            opStr = opStr + "\\\'8b"
          when 8216
            opStr = opStr + "\\\'91"
          when 8217
            opStr = opStr + "\\\'92"
          when 8220
            opStr = opStr + "\\\'93"
          when 8221
            opStr = opStr + "\\\'94"
          when 8250
            opStr = opStr + "\\\'9b"
          when 8211 #&ndash;
            opStr = opStr + "-"
          else
            opStr = opStr + "_"
        end
      end
      i = i + 1
    end
    return opStr
  end
end