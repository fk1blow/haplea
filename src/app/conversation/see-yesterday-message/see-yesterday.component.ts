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
  selector: 'hap-see-yesterday-message',
  templateUrl: './see-yesterday.component.html',
  styleUrls: ['./see-yesterday.component.scss']
})
export class SeeYesterdatMessageComponent implements OnInit {

  @Input() value: Record<string, any>

  response: EntryResponse[] = []

  constructor(private http: HttpClient) { }

  ngOnInit() {
    const params = new HttpParams()
      .set('intent', 'see-yesterday')
      .set('unit', 'day')
      .set('value', '1')

    this.http.get('http://localhost:4000/api/expenses', { params })
      .subscribe((r: { data: EntryResponse[] }) => {
        this.response = r.data
      })
  }

}
