import 'package:flutter/material.dart';

import 'fade_route.dart';

nextPagewithReplacement(context, Widget page) {
  Navigator.pushReplacement(context, FadeRoute(page: page));
}

removeAllBackStack(context, Widget page) {
  Navigator.of(context)
      .pushAndRemoveUntil(FadeRoute(page: page), (Route route) => false);
}

nextPage(context, Widget page) {
  Navigator.push(context, FadeRoute(page: page));
}

refreshPreviousPage(context, Widget page, Function __refresh) {
  Navigator.of(context)
      .push(
        new FadeRoute(page: page),
      )
      .then((val) => {__refresh()});
}
