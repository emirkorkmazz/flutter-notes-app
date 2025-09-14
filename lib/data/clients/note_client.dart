import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart' hide Headers;

import '/core/core.dart';
import '/data/data.dart';

part 'note_client.g.dart';

@RestApi()
abstract class NoteClient {
  factory NoteClient(Dio dio, {String baseUrl}) = _NoteClient;

  ///
  @GET(AppUrls.getNotes)
  Future<HttpResponse<GetNotesResponse>> getNotes();

  ///
  @POST(AppUrls.createNote)
  Future<HttpResponse<CreateNoteResponse>> createNote(
    @Body() CreateNoteRequest request,
  );

  ///
  @PUT(AppUrls.updateNote)
  Future<HttpResponse<UpdateNoteResponse>> updateNote(
    @Path('id') String id,
    @Body() UpdateNoteRequest request,
  );

  ///
  @DELETE(AppUrls.deleteNote)
  Future<HttpResponse<DeleteNoteResponse>> deleteNote(@Path('id') String id);

  ///
  @GET(AppUrls.getNoteById)
  Future<HttpResponse<GetNoteByIdResponse>> getNoteById(@Path('id') String id);

  ///
  @PATCH(AppUrls.restoreNote)
  Future<HttpResponse<RestoreNoteResponse>> restoreNote(@Path('id') String id);

  ///
  @GET(AppUrls.getAiSuggestions)
  Future<HttpResponse<GetAiSuggestionResponse>> getAiSuggestions(
    @Path('id') String id,
  );
}
