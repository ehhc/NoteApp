import 'package:boostnote_mobile/business_logic/model/SnippetNote.dart';
import 'package:boostnote_mobile/business_logic/service/FolderService.dart';
import 'package:boostnote_mobile/business_logic/service/NoteService.dart';
import 'package:boostnote_mobile/data/entity/FolderEntity.dart';
import 'package:boostnote_mobile/data/entity/SnippetNoteEntity.dart';
import 'package:boostnote_mobile/presentation/navigation/NavigationService.dart';
import 'package:boostnote_mobile/presentation/screens/ActionConstants.dart';
import 'package:boostnote_mobile/presentation/screens/editor/snippet_editor/widgets/CodeSnippetAppBar.dart';
import 'package:boostnote_mobile/presentation/widgets/buttons/AddFloatingActionButton.dart';
import 'package:boostnote_mobile/presentation/widgets/dialogs/AddSnippetDialog.dart';
import 'package:boostnote_mobile/presentation/widgets/dialogs/EditTagsDialog.dart';
import 'package:boostnote_mobile/presentation/widgets/dialogs/NoteInfoDialog.dart';
import 'package:boostnote_mobile/presentation/widgets/dialogs/SnippetDescription.dart';
import 'package:boostnote_mobile/presentation/widgets/snippet/CodeTab.dart';
import 'package:boostnote_mobile/presentation/widgets/snippet/SnippetNoteHeader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CodeSnippetEditor extends StatefulWidget {

  final SnippetNote _note;

  CodeSnippetEditor(this._note);

  @override
  State<StatefulWidget> createState() => CodeSnippetEditorState();
}
  

class CodeSnippetEditorState extends State<CodeSnippetEditor> with WidgetsBindingObserver {

  NavigationService _newNavigationService;
  NoteService _noteService;
  FolderService _folderService;

  List<FolderEntity> _folders;
  FolderEntity _dropdownValueFolder;
  bool _editMode;
  CodeSnippet _selectedCodeSnippet;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _newNavigationService = NavigationService();
    _noteService = NoteService();
    _folderService = FolderService();
    _folders = List();
    _editMode = false;
    if(this.widget._note.codeSnippets != null && this.widget._note.codeSnippets.isNotEmpty){
       _selectedCodeSnippet = this.widget._note.codeSnippets.first;
    } 
   
    _folderService.findAllUntrashed().then((folders) { 
      setState(() { 
        _folders = folders;
         _dropdownValueFolder = _folders.firstWhere((folder) => folder.id == this.widget._note.folder.id);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    NoteService().save(this.widget._note);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      NoteService().save(this.widget._note);    //TODO double save?
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _selectedCodeSnippet == null ? _buildEmptyBody() : _buildBody(),
      floatingActionButton: _editMode ? null : _buildFloatingActionButton(context)
    );
  }

  Widget _buildAppBar(BuildContext context) {
    if(_editMode) {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColorLight), 
          onPressed: () {
            _newNavigationService.navigateBack(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check), 
            onPressed: () {
              setState(() {
                _editMode = !_editMode;
              });
            }
          )
        ]
      );
    } else {
      return CodeSnippetAppBar(
        note: this.widget._note, 
        selectedCodeSnippet: _selectedCodeSnippet,
        selectedActionCallback: (String action) => _selectedAction(action),
        onNavigateBackCallback: () => _newNavigationService.navigateBack(context), 
        onSelectedSnippetChanged: (CodeSnippet codeSnippet) {
          setState(() {
            _selectedCodeSnippet = codeSnippet;
          });
        }
      );
    }
  }

  Widget _buildBody(){ 
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child:  SnippetNoteHeader(
            note: this.widget._note,
            selectedFolder: _dropdownValueFolder,
            selectedCodeSnippet: _selectedCodeSnippet,
            folders: _folders,
            onTitleChangedCallback: (String title) => this.widget._note.title = title,
            onFolderChangedCallback: (FolderEntity folder) {
              this.widget._note.folder = folder;
              _noteService.save(this.widget._note);
            },
            onCodeSnippetChangedCallback: (CodeSnippet codeSnippet) {
              setState(() {
                _selectedCodeSnippet = codeSnippet;
              });
            },
            onTagClickedCallback: () => _showTagDialog(context, this.widget._note.tags),
            onInfoClickedCallback: () => _showNoteInfoDialog(this.widget._note),
            onDescriptionClickCallback: () => _showDescriptionDialog(
              context, 
              this.widget._note,  
              (text){
                this.widget._note.description = text;
                _noteService.save(this.widget._note);
              }
            )
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: CodeTab(
            _selectedCodeSnippet, 
            _editMode, 
            (String text) => _onTextChangedCallback(text), 
            (bool editMode) {
              setState(() {
                _editMode = editMode;
              });
            }
          )
        )
      ],
    );
  }

  Widget _buildEmptyBody(){ 
    return ListView(
      children: <Widget>[
        SnippetNoteHeader(
          note: this.widget._note,
          selectedFolder: _dropdownValueFolder,
          folders: _folders,
          onTitleChangedCallback: (String title) => this.widget._note.title = title,
          onFolderChangedCallback: (FolderEntity folder) {
            this.widget._note.folder = folder;
            _noteService.save(this.widget._note);
          },
          onTagClickedCallback: () => _showTagDialog(context, this.widget._note.tags),
          onInfoClickedCallback: () => _showNoteInfoDialog(this.widget._note),
          onDescriptionClickCallback: () => _showDescriptionDialog(
              context, 
              this.widget._note,  
              (text){
                this.widget._note.description = text;
                _noteService.save(this.widget._note);
              }
            )
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container()
        )
      ],
    );
  }

  AddFloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return AddFloatingActionButton(
      onPressed: () => _showAddSnippetDialog(context, (text){
        setState(() {
          List<String> s = text.split('.');
          CodeSnippet codeSnippet;
          if(s.length > 1){
             codeSnippet = CodeSnippetEntity(linesHighlighted: new List(),  //TODO CodeSnippetEntity...
                                                      name: s[0],
                                                      mode: s[1],
                                                      content: '');
              this.widget._note.codeSnippets.add(codeSnippet);
          } else {
            codeSnippet = CodeSnippetEntity(linesHighlighted: new List(),  //TODO CodeSnippetEntity...
                                                      name: text,
                                                      mode: '',
                                                      content: '');
              this.widget._note.codeSnippets.add(codeSnippet);
          }
          _selectedCodeSnippet = codeSnippet;
        });
        Navigator.of(context).pop();
      })
     );
  }

  void _selectedAction(String action){
      if(action == ActionConstants.DELETE_ACTION){
        /*_noteService.moveToTrash(this.widget._note);
        _newNavigationService.navigateBack(context);*/
      } else if(action == ActionConstants.SAVE_ACTION){
        _noteService.save(this.widget._note);
        _newNavigationService.navigateBack(context);
      } else if(action == ActionConstants.MARK_ACTION){
        this.widget._note.isStarred = true;
        _noteService.save(this.widget._note);
      } else if(action == ActionConstants.UNMARK_ACTION){
        this.widget._note.isStarred = false;
        _noteService.save(this.widget._note);
      } 
  }

  void _onTextChangedCallback(String text){
       _selectedCodeSnippet.content = text;
  }

  Future<List<String>> _showTagDialog(BuildContext context, List<String> tags) => showDialog(
    context: context, 
    builder: (context){
      return EditTagsDialog(
        tags: tags, 
        saveCallback: (selectedTags){
          selectedTags.forEach((t) => print(t));
          NoteService service = NoteService();  
          service.save(this.widget._note);
          Navigator.of(context).pop();
        },
        cancelCallback: (){
          Navigator.of(context).pop();
        },
      );
  });

  Future<List<String>> _showNoteInfoDialog(SnippetNote note) => showDialog(
    context: context, 
    builder: (context){
      return NoteInfoDialog(note);
  });

  Future<String> _showDescriptionDialog(BuildContext context, SnippetNote note, Function(String) callback) =>
    showDialog(
      context: context,  
      builder: (context){
        return SnippetDescriptionDialog(textEditingController: TextEditingController(), note: note, onDescriptionChanged: callback);
  });

  Future<String> _showAddSnippetDialog(BuildContext context, Function(String) callback) =>
    showDialog(context: context, 
      builder: (context){
        return AddSnippetDialog(controller: TextEditingController(), onSnippetAdded: callback);
  });

}





 