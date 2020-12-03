part of 'package:address_search_field/address_search_field.dart';

/// Custom [StatefulBuilder] to create a [Widget] like [AddressSearchDialog].
class AddressSearchBuilder extends StatefulWidget {
  /// Constructor for [AddressSearchBuilder].
  const AddressSearchBuilder({
    @required this.geoMethods,
    @required this.controller,
    @required this.builder,
  })  : assert(geoMethods != null),
        assert(controller != null),
        assert(builder != null),
        this._addressId = null,
        this._addrComm = null,
        super();

  /// Constructor for [AddressSearchBuilder] to show an [AddressSearchDialog].
  factory AddressSearchBuilder.deft({
    @required GeoMethods geoMethods,
    @required TextEditingController controller,
    @required AddressDialogBuilder builder,
    @required FutureOr<void> Function(Address address) onDone,
  }) {
    assert(geoMethods != null);
    assert(controller != null);
    assert(builder != null);
    assert(onDone != null);
    return AddressSearchBuilder._(
        geoMethods,
        controller,
        (BuildContext context, AsyncSnapshot<List<Address>> snapshot,
                {TextEditingController controller,
                Future<void> Function() searchAddress,
                Future<Address> Function(Address address) getGeometry}) =>
            AddressSearchDialog._fromBuilder(
                snapshot,
                controller,
                searchAddress,
                getGeometry,
                builder.color,
                builder.backgroundColor,
                builder.hintText,
                builder.noResultsText,
                builder.cancelText,
                builder.continueText,
                builder.useButtons,
                onDone,
                null,
                null),
        null,
        null);
  }

  /// Constructor for [AddressSearchBuilder] to be called by [RouteSearchBox].
  const AddressSearchBuilder._fromBox(
    this.geoMethods,
    this.controller,
    this._addressId,
    this._addrComm,
  )   : this.builder = null,
        super();

  /// Constructor for [AddressSearchBuilder] to be called by [builder].
  const AddressSearchBuilder._(
    this.geoMethods,
    this.controller,
    this.builder,
    this._addressId,
    this._addrComm,
  ) : super();

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// controller for text used to search an [Address].
  final TextEditingController controller;

  /// Called to obtain the child widget.
  final Widget Function(
    BuildContext context,
    AsyncSnapshot<List<Address>> snapshot, {
    TextEditingController controller,
    Future<void> Function() searchAddress,
    Future<Address> Function(Address address) getGeometry,
  }) builder;

  /// Identifies the [Address] to work in the [Widget] built.
  final AddressId _addressId;

  /// Permits to work with the found [Address] by a [RouteSearchBox].
  final _AddrComm _addrComm;

  /// Builder for a custom [Widget].
  Widget build(
      Widget Function(
    BuildContext context,
    AsyncSnapshot<List<Address>> snapshot, {
    TextEditingController controller,
    Future<void> Function() searchAddress,
    Future<Address> Function(Address address) getGeometry,
  })
          widgetBuilder) {
    assert(this.builder == null,
        'this method just can be called when this widget is a child of [RouteSearchBox]');
    assert(widgetBuilder != null, 'this method has to build a widget');
    return AddressSearchBuilder._(this.geoMethods, this.controller,
        widgetBuilder, this._addressId, this._addrComm);
  }

  /// Builder for an [AddressSearchDialog].
  Widget buildDefault({
    @required AddressDialogBuilder builder,
    @required FutureOr<void> Function(Address address) onDone,
  }) {
    assert(this.builder == null,
        'this method just can be called when this widget is a child of [RouteSearchBox]');
    assert(builder != null);
    assert(onDone != null);
    return AddressSearchBuilder._(
        this.geoMethods,
        this.controller,
        (BuildContext context, AsyncSnapshot<List<Address>> snapshot,
                {TextEditingController controller,
                Future<void> Function() searchAddress,
                Future<Address> Function(Address address) getGeometry}) =>
            AddressSearchDialog._fromBuilder(
                snapshot,
                controller,
                searchAddress,
                getGeometry,
                builder.color,
                builder.backgroundColor,
                builder.hintText,
                builder.noResultsText,
                builder.cancelText,
                builder.continueText,
                builder.useButtons,
                onDone,
                this._addrComm,
                this._addressId),
        this._addressId,
        this._addrComm);
  }

  @override
  _AddressSearchBuilderState createState() => _AddressSearchBuilderState();
}

class _AddressSearchBuilderState extends State<AddressSearchBuilder> {
  AsyncSnapshot<List<Address>> _snapshot =
      AsyncSnapshot<List<Address>>.nothing();

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _snapshot,
        controller: widget.controller,
        searchAddress: _searchAddress,
        getGeometry: _getGeometry,
      );

  /// Loads a list of found addresses by the text in [widget.controller].
  Future<void> _searchAddress() async {
    if (mounted)
      setState(() => _snapshot = AsyncSnapshot<List<Address>>.waiting());
    final List<Address> data = await widget.geoMethods
        .autocompletePlace(query: widget.controller.text);
    if (mounted)
      setState(() => _snapshot = (data == null)
          ? AsyncSnapshot<List<Address>>.withError(
              ConnectionState.done, NullThrownError())
          : AsyncSnapshot<List<Address>>.withData(ConnectionState.done, data));
  }

  /// Tries to get a completed [Address] object by a reference or place id.
  Future<Address> _getGeometry(Address address) async {
    final addr = await widget.geoMethods.getPlaceGeometry(
      reference: address.reference,
      placeId: address.placeId,
    );
    if (widget._addressId == null || widget._addrComm == null) return addr;
    widget._addrComm.writeAddr(widget._addressId, addr ?? address);
    return addr;
  }
}
