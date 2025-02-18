import { Migration } from '@nocobase/server';

export default class AlertSubTableMigration extends Migration {
  async up() {
    const match = await this.app.version.satisfies('<=0.7.4-alpha.8');
    if (!match) {
      return;
    }
    const Field = this.context.db.getRepository('fields');
    const existed = await Field.count({
      filter: {
        name: 'phone',
        collectionName: 'users'
      }
    });
    if (!existed) {
      await Field.create({
        values: {
          name: 'phone',
          collectionName: 'users',
          type: 'string',
          unique: true,
          interface: 'phone',
          uiSchema: {
            type: 'string',
            title: '{{t("Phone")}}',
            'x-component': 'Input',
            'x-validator': 'phone',
            require: true,
          },
        },
        // NOTE: to trigger hook
        context: {}
      });
    }
  }

  async down() {

  }
}
