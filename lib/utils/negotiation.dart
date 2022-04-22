class Negotiation {
  int id, transportistId, vehicleId, generatorId, loadId;
  String state;
  Negotiation(
      {this.id = 0,
      this.transportistId = 0,
      this.vehicleId = 0,
      this.generatorId = 0,
      this.loadId = 0,
      this.state = ''});

  startNegotiation() async {
    try {} catch (e) {
      return false;
    }
  }

  acceptNegotiation() {}

  rejectNegotiation() {}

  showNegotiation() {}
}
