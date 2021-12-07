import 'dart:math' as math;

import 'package:ampama/scoped_models/main_scoped.dart';
import 'package:flutter/material.dart';
import '../pages/requests_list.dart';
import 'package:toast/toast.dart';

class HomeFab extends StatefulWidget {
  final MainModel model;

  HomeFab(this.model);
  @override
  State<StatefulWidget> createState() {
    return _HomeFabState();
  }
}

class _HomeFabState extends State<HomeFab> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              heroTag: 'My requests',
              mini: true,
              onPressed: () {
                _controller.reset();
                if (widget.model.user == null) {
                   Toast.show("Sign in first to see all your Requests", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  Navigator.pushNamed(context,'/auth');
                  return;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            RequestList(widget.model, true)));
              },
              child: Icon(
                Icons.view_list,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              heroTag: 'Upload Design',
              mini: true,
              onPressed: () {
                _controller.reset();
                Navigator.pushNamed(context, '/upload_design');
              },
              child: Icon(
                Icons.input,
                color: Colors.red,
              ),
            ),
          ),
        ),
        FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          heroTag: 'options',
          onPressed: () {
            if (_controller.isDismissed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                child: Icon(
                    _controller.isDismissed ? Icons.more_vert : Icons.close),
              );
            },
          ),
        ),
      ],
    );
  }
}