import 'package:flutter/material.dart';
import 'package:poolinspection/src/elements/textlabel.dart';

class CustomXRadioGroup extends StatefulWidget {
  final String name;
  final String label;
  final String header;
  final String selected;
  final List<CustomOption> options;
  final bool required;
  final Function onSaved;
  CustomXRadioGroup(
      {this.name,
      this.label,
      this.options,
      this.header,
      this.selected,
      this.required = false,
      this.onSaved});

  @override
  _CustomXRadioGroupState createState() => _CustomXRadioGroupState();
}

class _CustomXRadioGroupState extends State<CustomXRadioGroup> {
  XFocusNode focusNode;
  String errorMsg;
  String _groupValue;

  @override
  void initState() {
    super.initState();
    focusNode = CustomXFormContainer.of(context).register(widget.name);
    String val = focusNode.defaultValue == null
        ? widget.selected
        : focusNode.defaultValue;
    _onSaved(val);
  }

  _onSaved(val) {
    setState(() {
      _groupValue = val;
    });
    CustomXFormContainer.of(context)
        .onSave(widget.name, _groupValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        textLabel(widget.header?? ''),
        Text(widget.label ?? ''),
        Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.options.map((CustomOption option) {
              return Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Radio(
                        value: option.value,
                        groupValue: _groupValue,
                        onChanged: (val) => _onSaved(val),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: RaisedButton(
                          onPressed: () => _onSaved(
                            option.value,
                          ),
                          // onHighlightChanged: ,
                          child: textLabel(option.name),
                        ),
                      )
                    ],
                  )
                ],
              );
            }).toList()),
      ],
    );
  }
}

class CustomXFormContainer extends StatefulWidget {
  final Widget child;
  final Function register;
  final Function onSave;
  final Function next;
  CustomXFormContainer(
      {@required this.child,
      @required this.register,
      @required this.onSave,
      @required this.next});

  static CustomXFormContainerState of(BuildContext context) {
    final CustomXFormContainerState scope = context
        .ancestorStateOfType(const TypeMatcher<CustomXFormContainerState>());
    return scope;
  }

  @override
  CustomXFormContainerState createState() {
    return new CustomXFormContainerState();
  }
}

class CustomXFormContainerState extends State<CustomXFormContainer> {
  register(name) {
    return widget.register(name);
  }

  onSave(field, value) {
    return widget.onSave(field, value);
  }

  next(focusNode) {
    return widget.next(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}

class XFocusNode {
  bool autoFocus = false;
  FocusNode focus;
  dynamic defaultValue;
  XFocusNode({this.focus, this.autoFocus = false, this.defaultValue});
}

class CustomOption {
  String name;
  String value;
  CustomOption({this.name, this.value});
}

class CustomXForm extends StatefulWidget {
  final Function nextPage;
  final Function prevPage;
  final Function submit;
  final bool autoValidate;
  final bool showButtons;
  final List<Widget> children;
  const CustomXForm(
      {Key key,
      this.children,
      @required this.submit,
      this.nextPage,
      this.prevPage,
      this.autoValidate = false,
      this.showButtons = true})
      : super(key: key);
  static CustomXFormState of(BuildContext context) {
    final _CustomXFormScope scope =
        context.inheritFromWidgetOfExactType(_CustomXFormScope);
    return scope?._formState;
  }

  @override
  CustomXFormState createState() => CustomXFormState();
}

class CustomXFormState extends State<CustomXForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PageController _controller = new PageController();
  Map<String, dynamic> formValues = {};
  bool autoValidate;
  List<FocusNode> _focusNodes = [];
  int page = 1;
  int pages;

  @override
  void initState() {
    super.initState();
    pages = widget.children.length;
    autoValidate = widget.autoValidate;
  }

  prevPage() {
    _formKey.currentState.save();
    if (page != 1) {
      setState(() {
        page = page - 1;
      });
      _controller.animateToPage(page - 1,
          curve: Curves.ease, duration: Duration(milliseconds: 200));
    }
  }

  nextPage() {
    _formKey.currentState.save();
    if (page != pages) {
      if (_formKey.currentState.validate()) {
        setState(() {
          autoValidate = false;
          page = page + 1;
        });
        _controller.animateToPage(page - 1,
            curve: Curves.ease, duration: Duration(milliseconds: 200));
      } else {
        setState(() {
          autoValidate = true;
        });
      }
    } else {
      submit();
    }
  }

  register(name) {
    XFocusNode xFocus = XFocusNode();
    if (_focusNodes.length == 0) {
      xFocus.autoFocus = true;
    }
    xFocus.focus = FocusNode();
    _focusNodes.add(xFocus.focus);
    if (formValues.containsKey(name)) {
      xFocus.defaultValue = formValues[name];
    }
    return xFocus;
  }

  submit() {
    setState(() {
      autoValidate = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      widget.submit(formValues);
    }
  }

  void onSave(field, value) {
    formValues.addEntries([new MapEntry(field, value)]);
  }

  void next(focusNode) {
    int i = _focusNodes.lastIndexOf(focusNode);
    if (i != _focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
    } else {
      if (page == pages) {
        submit();
      } else {
        nextPage();
      }
    }
  }

  _buildButtons(int pages) {
    var backButton = RaisedButton(
      child: Text("Previous"),
      onPressed: page != 1 ? () => prevPage() : null,
    );
    var nextButton = RaisedButton(
      child: Text("Next"),
      color: Theme.of(context).primaryColorLight,
      onPressed: () => nextPage(),
    );
    var submitButton = RaisedButton(
      child: Text("Submit"),
      color: Theme.of(context).primaryColorLight,
      onPressed: () => submit(),
    );
    List<Widget> buttons = [];
    if (widget.showButtons) {
      if (pages > 1) {
        buttons.add(backButton);
        buttons.add(Text("Page $page of $pages"));
      }
      if (pages == page) {
        buttons.add(submitButton);
      } else {
        buttons.add(nextButton);
      }
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: buttons);
  }

  @override
  Widget build(BuildContext context) {
    return CustomXFormContainer(
      register: (name) => register(name),
      onSave: (field, value) => onSave(field, value),
      next: (focusNode) => next(focusNode),
      child: Form(
          key: _formKey,
          autovalidate: autoValidate,
          child: Column(
            children: <Widget>[
              Flexible(
                child: PageView(
                    physics: ScrollPhysics(),
                    controller: _controller,
                    children: widget.children),
              ),
              Container(
                child: _buildButtons(pages),
              ),
            ],
          )),
    );
  }
}

class _CustomXFormScope extends InheritedWidget {
  const _CustomXFormScope({Key key, Widget child, CustomXFormState formState})
      : _formState = formState,
        // _generation = generation,
        super(key: key, child: child);

  final CustomXFormState _formState;

  /// Incremented every time a form field has changed. This lets us know when
  /// to rebuild the form.
  // final int _generation;

  /// The [Form] associated with this widget.
  // CustomXForm get form => _formState.widget;

  @override
  bool updateShouldNotify(_CustomXFormScope old) => true;
}
