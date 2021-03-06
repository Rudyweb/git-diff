path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'
etch = require('etch')

describe "git-diff:toggle-diff-list", ->
  [diffListView, editor] = []

  beforeEach ->
    projectPath = temp.mkdirSync('git-diff-spec-')
    fs.copySync(path.join(__dirname, 'fixtures', 'working-dir'), projectPath)
    fs.moveSync(path.join(projectPath, 'git.git'), path.join(projectPath, '.git'))
    atom.project.setPaths([projectPath])

    jasmine.attachToDOM(atom.views.getView(atom.workspace))

    waitsForPromise ->
      atom.packages.activatePackage('git-diff')

    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editor.setCursorBufferPosition([4, 29])
      editor.insertText('a')
      atom.commands.dispatch(atom.views.getView(editor), 'git-diff:toggle-diff-list')

    waitsForPromise ->
      etch.getScheduler().getNextUpdatePromise()

  it "shows a list of all diff hunks", ->
    diffListView = document.querySelector('.diff-list-view')
    expect(diffListView.textContent).toBe "while(items.length > 0) {a-5,1 +5,1"

  it "moves the cursor to the selected hunk", ->
    editor.setCursorBufferPosition([0, 0])
    atom.commands.dispatch(document.querySelector('.diff-list-view'), 'core:confirm')
    expect(editor.getCursorBufferPosition()).toEqual [4, 4]
