import { connectDatabase, disconnectDatabase } from '../config/database';
import { UserModel } from '../modules/users/user.model';
import { AuditService } from '../modules/audit/audit.service';
import { UserRole, UserRoleSchema } from '@acedex/contracts';

async function main() {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log('Usage: npx tsx src/scripts/promote-user.ts <email> <role>');
    console.log('Available roles: student, content_manager, admin, super_admin');
    process.exit(1);
  }

  const [email, rawRole] = args;
  const roleParse = UserRoleSchema.safeParse(rawRole);

  if (!roleParse.success) {
    console.error(`Invalid role: '${rawRole}'. Must be one of: ${UserRoleSchema.options.join(', ')}`);
    process.exit(1);
  }

  const targetRole = roleParse.data as UserRole;

  await connectDatabase();

  const user = await UserModel.findOne({ email: email.toLowerCase().trim() });
  if (!user) {
    console.error(`❌ User with email '${email}' not found.`);
    await disconnectDatabase();
    process.exit(1);
  }

  const oldRole = user.role;
  user.role = targetRole;
  await user.save();

  await AuditService.record({
    userId: user._id.toString(),
    userEmail: user.email,
    action: 'ROLE_PROMOTED_VIA_CLI',
    resource: 'users',
    resourceId: user._id.toString(),
    details: { oldRole, newRole: targetRole },
  });

  console.log(`✅ Successfully updated role for ${user.email}: ${oldRole} -> ${targetRole}`);
  await disconnectDatabase();
  process.exit(0);
}

main().catch((err) => {
  console.error('Fatal script error:', err);
  process.exit(1);
});
