import { Component, OnInit, Input } from '@angular/core';
import { HttpParams, HttpClient } from '@angular/common/http';

interface EntryResponse {
  id: number
  items: string[]
  merchandise: string[]
  spent_at: string
  sum: number
}

@Component({
  selector: 'hap-show-before-relative-message',
  templateUrl: './see-before-relative-message.html',
  styleUrls: ['./see-before-relative-message.scss']
})
export class SeeBeforeRelativeMessageComponent implements OnInit {

  @Input() value: Record<string, any>

  response: EntryResponse[] = []

  constructor(private http: HttpClient) { }

  ngOnInit() {
    const intent = this.value.data.name
    const entities = this.value.data.entities
    const duration = entities.duration[0]

    const params = new HttpParams()
      .set('intent', intent)
      .set('unit', duration.unit)
      .set('value', duration.value)

    this.http.get('http://localhost:4000/api/expenses', { params })
      .subscribe((r: { data: EntryResponse[] }) => {
        this.response = r.data
      })
  }

}
