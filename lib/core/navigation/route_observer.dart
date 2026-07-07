import 'package:flutter/material.dart';

/// Shared route observer for detecting when a route is popped back to.
/// Used e.g. to refetch bundle data when returning to pack course list.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
