import { Component, OnDestroy, OnInit, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface Departure {
  name: string;
  stop: string;
  time: string; // "HH:mm:ss"
  date: string; // "yyyy-MM-dd"
  direction: string;
  reachable: boolean;
  productAtStop?: { displayNumber?: string; line?: string };
}

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit, OnDestroy {
  private http = inject(HttpClient);

  private readonly direction = 'Karskär';
  private readonly maxShown = 3;
  private readonly refreshMs = 30_000;

  protected departures = signal<Departure[]>([]);
  protected now = signal(new Date());
  protected offline = signal(false);

  private tickTimer?: ReturnType<typeof setInterval>;
  private loadTimer?: ReturnType<typeof setInterval>;

  protected clock = computed(() => {
    const n = this.now();
    return `${String(n.getHours()).padStart(2, '0')}:${String(n.getMinutes()).padStart(2, '0')}`;
  });

  protected dateLabel = computed(() =>
    this.now().toLocaleDateString('sv-SE', { weekday: 'long', day: 'numeric', month: 'long' }),
  );

  protected upcoming = computed(() => {
    const now = this.now();
    return this.departures()
      .map((d) => ({ d, when: new Date(`${d.date}T${d.time}`) }))
      .filter((x) => x.when > now)
      .sort((a, b) => a.when.getTime() - b.when.getTime())
      .slice(0, this.maxShown)
      .map(({ d, when }) => {
        const mins = Math.floor((when.getTime() - now.getTime()) / 60000);
        return {
          key: `${d.date}T${d.time}`,
          line: d.productAtStop?.displayNumber ?? d.name,
          direction: d.direction,
          time: d.time.slice(0, 5),
          reachable: d.reachable,
          mins,
          etaClass: mins < 1 ? 'now' : mins <= 5 ? 'soon' : '',
        };
      });
  });

  ngOnInit(): void {
    this.load();
    this.loadTimer = setInterval(() => this.load(), this.refreshMs);
    this.tickTimer = setInterval(() => this.now.set(new Date()), 1000);
  }

  ngOnDestroy(): void {
    clearInterval(this.loadTimer);
    clearInterval(this.tickTimer);
  }

  private load(): void {
    this.http
      .get<Departure[]>('/api/departures', { params: { direction: this.direction } })
      .subscribe({
        next: (data) => {
          this.departures.set(data);
          this.offline.set(false);
        },
        error: () => this.offline.set(true),
      });
  }
}