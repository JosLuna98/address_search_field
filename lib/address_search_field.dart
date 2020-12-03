/// An address search field which helps to autocomplete an address by a reference.
/// It can be used to get Directions beetwen two points.
library address_search_field;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:address_search_field/src/utils/route_error.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:address_search_field/src/models/coords.dart';
import 'package:address_search_field/src/models/address.dart';
import 'package:address_search_field/src/models/directions.dart';

export 'package:address_search_field/src/utils/route_error.dart';
export 'package:address_search_field/src/services/geo_methods.dart';
export 'package:address_search_field/src/models/directions.dart';
export 'package:address_search_field/src/models/address.dart';
export 'package:address_search_field/src/models/bounds.dart';
export 'package:address_search_field/src/models/coords.dart';

part 'package:address_search_field/src/widgets/route_search_box.dart';
part 'package:address_search_field/src/widgets/address_search_builder.dart';
part 'package:address_search_field/src/widgets/address_search_dialog.dart';
part 'package:address_search_field/src/models/addr_comm.dart';
part 'package:address_search_field/src/models/waypoints_manager.dart';
part 'package:address_search_field/src/utils/address_id.dart';
