import 'package:flutter/material.dart';

import 'BlockButtonWidget.dart';

class MultiPageForm extends StatefulWidget {
  final VoidCallback onFormSubmitted;
  final int totalPage;
  final Widget nextButtonStyle;
  final Widget previousButtonStyle;
  final Widget submitButtonStyle;
  final List<Widget> pageList;
  MultiPageForm(
      {@required this.totalPage,
      @required this.pageList,
      @required this.onFormSubmitted,
      this.nextButtonStyle,
      this.previousButtonStyle,
      this.submitButtonStyle});
  _MultiPageFormState createState() => _MultiPageFormState();
}

class _MultiPageFormState extends State<MultiPageForm> {
  int totalPage;
  int currentPage = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalPage = widget.totalPage;
  }

  Widget getNextButtonWrapper(Widget child) {
    if (widget.nextButtonStyle != null) {
      return child;
    } else {
      return Text("Next",style: TextStyle(color: Colors.white),);
    }
  }

  Widget getPreviousButtonWrapper(Widget child) {
    if (widget.previousButtonStyle != null) {
      return child;
    } else {
      return Text("Previous",style: TextStyle(color: Colors.white),);
    }
  }

  Widget getSubmitButtonWrapper(Widget child) {
    if (widget.previousButtonStyle != null) {
      return child;
    } else {
      return Text("Submit",style: TextStyle(color: Colors.white),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: pageHolder(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                currentPage == 1
                    ? Container()
                    : RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: getPreviousButtonWrapper(
                            widget.previousButtonStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = currentPage - 1;
                          });
                        },
                      ),
                currentPage == totalPage
                    ? RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: getSubmitButtonWrapper(widget.submitButtonStyle),
                        onPressed: widget.onFormSubmitted,
                      )
                    : RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: getNextButtonWrapper(widget.nextButtonStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = currentPage + 1;
                          });
                        },
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget pageHolder() {
    for (int i = 1; i <= totalPage; i++) {
      if (currentPage == i) {
        return widget.pageList[i - 1];
      }
    }
    return Container();
  }
}
