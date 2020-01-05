import {
    AfterViewInit,
    Component,
    ElementRef,
    EventEmitter,
    Input,
    OnInit,
    Output,
    ViewChild
} from '@angular/core';

@Component({
  selector: 'hap-editor',
  templateUrl: './editor.component.html',
  styleUrls: ['./editor.component.scss']
})
export class EditorComponent implements OnInit, AfterViewInit {

  @Input() autofocus = false

  @ViewChild('editor', { static: true }) editorRef: ElementRef

  @Output() change = new EventEmitter<string>()

  constructor() { }

  focus() {
    this.editorRef.nativeElement.focus()
  }

  ngOnInit() {
    document.execCommand("defaultParagraphSeparator", false, "div")
  }

  ngAfterViewInit() {
    this.autofocus && this.editorRef.nativeElement.focus()
  }

  onEditorInput(_evt: KeyboardEvent) {
    const text = this.editorRef.nativeElement.innerText
    // this is too costly
    // this.change.emit(text.split('\n').filter(l => l.length !== 0))
    this.change.emit(text)
  }

}
