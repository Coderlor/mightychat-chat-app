enum RequestStatus { Pending, Rejected, Accepted }

extension status on RequestStatus {
  String get statusName {
    switch (this) {
      case RequestStatus.Pending:
        return 'Pending';

      case RequestStatus.Rejected:
        return 'Rejected';

      case RequestStatus.Accepted:
        return 'Accepted';
    }
  }
}