import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'text_field_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TextFieldData> _textFields = [];
  final List<List<TextFieldData>> _undoStack = [];
  final List<List<TextFieldData>> _redoStack = [];

  Color _textColor = Colors.black;
  String _fontFamily = 'Arial';
  bool _isBold = false;
  bool _isItalic = false;
  double _fontSize = 14.0;
  TextFieldData? _selectedTextField;

  void _addTextField() {
    setState(() {
      _textFields.add(
        TextFieldData(
          offset: const Offset(50, 50),
          textStyle: TextStyle(
            color: _textColor,
            fontFamily: _fontFamily,
            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
            fontSize: _fontSize,
          ),
          controller: TextEditingController(),
          isEmpty: true,
        ),
      );
      changeUndoState();
    });
  }

  void _changeTextColor(Color color) {
    setState(() {
      _textColor = color;
      if (_selectedTextField != null) {
        _selectedTextField!.textStyle =
            _selectedTextField!.textStyle.copyWith(color: color);
      }
      changeUndoState();
    });
  }

  void _changeFontFamily(String fontFamily) {
    setState(() {
      _fontFamily = fontFamily;
      if (_selectedTextField != null) {
        _selectedTextField!.textStyle =
            _selectedTextField!.textStyle.copyWith(fontFamily: fontFamily);
      }
      changeUndoState();
    });
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
      if (_selectedTextField != null) {
        _selectedTextField!.textStyle = _selectedTextField!.textStyle.copyWith(
          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        );
      }
      changeUndoState();
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
      if (_selectedTextField != null) {
        _selectedTextField!.textStyle = _selectedTextField!.textStyle.copyWith(
          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        );
      }
      changeUndoState();
    });
  }

  void _changeFontSize(double size) {
    setState(() {
      _fontSize = size;
      if (_selectedTextField != null) {
        _selectedTextField!.textStyle =
            _selectedTextField!.textStyle.copyWith(fontSize: size);
      }
      changeUndoState();
    });
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(_textFields.map((e) => e.copy()).toList());
      setState(() {
        _textFields.clear();
        _textFields.addAll(_undoStack.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(_textFields.map((e) => e.copy()).toList());
      setState(() {
        _textFields.clear();
        _textFields.addAll(_redoStack.removeLast());
      });
    }
  }

  void changeUndoState() {
    _undoStack.add(_textFields.map((e) => e.copy()).toList());
    _redoStack.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Celebrare Task', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.white),
            onPressed: _redo,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTextField = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.purple[200]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          ..._textFields.map((fieldData) {
            return Positioned(
              left: fieldData.offset.dx,
              top: fieldData.offset.dy,
              child: Draggable<TextFieldData>(
                childWhenDragging: Container(),
                data: fieldData,
                feedback: Material(
                  child: _buildTextField(fieldData, true),
                ),
                onDragEnd: (details) {
                  setState(() {
                    fieldData.offset = Offset(
                      details.offset.dx,
                      details.offset.dy -
                          AppBar().preferredSize.height -
                          kToolbarHeight,
                    );
                  });
                  changeUndoState();
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTextField = fieldData;
                    });
                  },
                  child: _buildTextField(fieldData,
                      fieldData == _selectedTextField || fieldData.isEmpty),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: _selectedTextField != null
          ? _buildEditingToolbar()
          : FloatingActionButton(
              onPressed: _addTextField,
              child: const Icon(Icons.add),
              backgroundColor: Colors.deepPurple,
            ),
    );
  }

  Widget _buildTextField(TextFieldData fieldData, bool showBorder) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(
            8.0), // Increased padding for larger touch area
        decoration: BoxDecoration(
          border: showBorder ? Border.all(color: Colors.black) : null,
        ),
        child: TextField(
          controller: fieldData.controller,
          style: fieldData.textStyle,
          maxLines: null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.transparent,
            filled: true,
          ),
          onChanged: (text) {
            setState(() {
              fieldData.isEmpty = text.isEmpty;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEditingToolbar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.white,
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Select Color'),
                          content: BlockPicker(
                            pickerColor: _textColor,
                            onColorChanged: _changeTextColor,
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _textColor,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10),
                  value: _fontFamily,
                  onChanged: (String? value) {
                    if (_selectedTextField != null) {
                      _changeFontFamily(value!);
                    }
                  },
                  items: <String>[
                    'Arial',
                    'Courier',
                    'Times New Roman',
                    'Verdana',
                    'Georgia',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 20),
                DropdownButton<double>(
                  borderRadius: BorderRadius.circular(10),
                  value: _fontSize,
                  onChanged: (double? value) {
                    if (_selectedTextField != null) {
                      _changeFontSize(value!);
                    }
                  },
                  items: <double>[
                    8.0,
                    12.0,
                    14.0,
                    16.0,
                    20.0,
                    24.0,
                    30.0,
                    36.0,
                    48.0,
                    60.0,
                    72.0,
                  ].map<DropdownMenuItem<double>>((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text(value.toStringAsFixed(1)),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    Icons.format_bold,
                    color: _isBold ? Colors.black : Colors.grey,
                  ),
                  onPressed: () {
                    if (_selectedTextField != null) {
                      _toggleBold();
                    }
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    Icons.format_italic,
                    color: _isItalic ? Colors.black : Colors.grey,
                  ),
                  onPressed: () {
                    if (_selectedTextField != null) {
                      _toggleItalic();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
