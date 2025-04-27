abstract interface class INetworkService {
  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data);
  Future<Map<String, dynamic>> get(String url, {Map<String, dynamic>? params});
}
