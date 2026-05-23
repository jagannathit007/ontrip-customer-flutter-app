class ResponseClass<T> {
  String msg;
  bool isSuccess;
  bool isLoading;
  bool isRefresh;
  int totalCount;
  T? data;

  ResponseClass({
    this.msg = 'Something went wrong',
    this.isSuccess = false,
    this.isLoading = false,
    this.isRefresh = true,
    this.totalCount = 0,
    this.data,
  });
}
